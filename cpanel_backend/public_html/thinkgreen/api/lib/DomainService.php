<?php
declare(strict_types=1);

function activity_points_from_definition(PDO $pdo, int $definitionId): int
{
    $stmt = $pdo->prepare('SELECT default_points FROM activity_definitions WHERE id = :id LIMIT 1');
    $stmt->execute([':id' => $definitionId]);
    $row = $stmt->fetch();
    return (int)($row['default_points'] ?? 0);
}

function upsert_points_event(
    PDO $pdo,
    int $userId,
    int $pointsDelta,
    string $reasonCode,
    ?string $referenceType,
    ?int $referenceId,
    ?string $note = null
): void {
    $check = $pdo->prepare(
        'SELECT id FROM points_ledger
         WHERE user_id = :user_id
           AND reason_code = :reason_code
           AND ' . ($referenceType === null ? 'reference_type IS NULL' : 'reference_type = :reference_type') . '
           AND ' . ($referenceId === null ? 'reference_id IS NULL' : 'reference_id = :reference_id') . '
         LIMIT 1'
    );

    $params = [
        ':user_id' => $userId,
        ':reason_code' => $reasonCode,
    ];

    if ($referenceType !== null) {
        $params[':reference_type'] = $referenceType;
    }
    if ($referenceId !== null) {
        $params[':reference_id'] = $referenceId;
    }

    $check->execute($params);
    if ($check->fetch()) {
        return;
    }

    $stmt = $pdo->prepare(
        'INSERT INTO points_ledger (user_id, points_delta, reason_code, reference_type, reference_id, note, created_at)
         VALUES (:user_id, :points_delta, :reason_code, :reference_type, :reference_id, :note, UTC_TIMESTAMP())'
    );

    $stmt->execute([
        ':user_id' => $userId,
        ':points_delta' => $pointsDelta,
        ':reason_code' => $reasonCode,
        ':reference_type' => $referenceType,
        ':reference_id' => $referenceId,
        ':note' => $note,
    ]);
}

function refresh_user_points(PDO $pdo, int $userId): int
{
    $stmt = $pdo->prepare('SELECT COALESCE(SUM(points_delta), 0) AS balance FROM points_ledger WHERE user_id = :user_id');
    $stmt->execute([':user_id' => $userId]);
    $balance = (int)($stmt->fetch()['balance'] ?? 0);

    $update = $pdo->prepare('UPDATE users SET points_balance = :balance WHERE id = :user_id');
    $update->execute([':balance' => $balance, ':user_id' => $userId]);

    return $balance;
}

function sync_user_challenges(PDO $pdo, int $userId): void
{
    $challenges = $pdo->query(
        'SELECT id, points_bonus, target_count, linked_activity_definition_id
         FROM challenges
         WHERE is_active = 1'
    )->fetchAll();

    foreach ($challenges as $challenge) {
        $countStmt = $pdo->prepare(
            'SELECT COUNT(*) AS total
             FROM activities
             WHERE user_id = :user_id
               AND status = "approved"
               AND activity_definition_id = :definition_id'
        );
        $countStmt->execute([
            ':user_id' => $userId,
            ':definition_id' => $challenge['linked_activity_definition_id'],
        ]);
        $approvedCount = (int)($countStmt->fetch()['total'] ?? 0);
        $isCompleted = $approvedCount >= (int)$challenge['target_count'] ? 1 : 0;

        $currentRowStmt = $pdo->prepare(
            'SELECT id, reward_granted
             FROM user_challenges
             WHERE user_id = :user_id AND challenge_id = :challenge_id
             LIMIT 1'
        );
        $currentRowStmt->execute([
            ':user_id' => $userId,
            ':challenge_id' => $challenge['id'],
        ]);
        $existing = $currentRowStmt->fetch();

        if ($existing) {
            $update = $pdo->prepare(
                'UPDATE user_challenges
                 SET current_count = :current_count,
                     is_completed = :is_completed,
                     completed_at = CASE
                         WHEN :is_completed = 1 AND completed_at IS NULL THEN UTC_TIMESTAMP()
                         ELSE completed_at
                     END,
                     updated_at = UTC_TIMESTAMP()
                 WHERE id = :id'
            );
            $update->execute([
                ':current_count' => $approvedCount,
                ':is_completed' => $isCompleted,
                ':id' => $existing['id'],
            ]);

            $rewardGranted = (int)$existing['reward_granted'] === 1;
        } else {
            $insert = $pdo->prepare(
                'INSERT INTO user_challenges
                 (user_id, challenge_id, current_count, is_completed, completed_at, reward_granted, reward_granted_at, updated_at)
                 VALUES
                 (:user_id, :challenge_id, :current_count, :is_completed,
                  CASE WHEN :is_completed = 1 THEN UTC_TIMESTAMP() ELSE NULL END,
                  0, NULL, UTC_TIMESTAMP())'
            );
            $insert->execute([
                ':user_id' => $userId,
                ':challenge_id' => $challenge['id'],
                ':current_count' => $approvedCount,
                ':is_completed' => $isCompleted,
            ]);
            $rewardGranted = false;
        }

        if ($isCompleted === 1 && !$rewardGranted) {
            upsert_points_event(
                $pdo,
                $userId,
                (int)$challenge['points_bonus'],
                'challenge_completed',
                'challenge',
                (int)$challenge['id'],
                'Challenge completion bonus'
            );

            $grant = $pdo->prepare(
                'UPDATE user_challenges
                 SET reward_granted = 1, reward_granted_at = UTC_TIMESTAMP()
                 WHERE user_id = :user_id AND challenge_id = :challenge_id'
            );
            $grant->execute([
                ':user_id' => $userId,
                ':challenge_id' => $challenge['id'],
            ]);
        }
    }

    refresh_user_points($pdo, $userId);
}

function approve_activity_and_award(PDO $pdo, int $activityId, int $adminUserId, ?string $reviewNotes = null): array
{
    $stmt = $pdo->prepare(
        'SELECT a.*, ad.default_points
         FROM activities a
         LEFT JOIN activity_definitions ad ON ad.id = a.activity_definition_id
         WHERE a.id = :activity_id
         LIMIT 1'
    );
    $stmt->execute([':activity_id' => $activityId]);
    $activity = $stmt->fetch();

    if (!$activity) {
        respond_error('Activity not found.', 404);
    }

    $points = (int)$activity['points_awarded'];
    if ($points <= 0) {
        $points = (int)($activity['default_points'] ?? 0);
    }

    $update = $pdo->prepare(
        'UPDATE activities
         SET status = "approved",
             points_awarded = :points_awarded,
             review_notes = :review_notes,
             reviewed_by = :reviewed_by,
             reviewed_at = UTC_TIMESTAMP(),
             updated_at = UTC_TIMESTAMP()
         WHERE id = :activity_id'
    );
    $update->execute([
        ':points_awarded' => $points,
        ':review_notes' => $reviewNotes,
        ':reviewed_by' => $adminUserId,
        ':activity_id' => $activityId,
    ]);

    upsert_points_event(
        $pdo,
        (int)$activity['user_id'],
        $points,
        'activity_approved',
        'activity',
        (int)$activityId,
        'Activity approved by admin'
    );

    sync_user_challenges($pdo, (int)$activity['user_id']);

    return [
        'activity_id' => (int)$activityId,
        'user_id' => (int)$activity['user_id'],
        'points_awarded' => $points,
        'new_balance' => refresh_user_points($pdo, (int)$activity['user_id']),
    ];
}
