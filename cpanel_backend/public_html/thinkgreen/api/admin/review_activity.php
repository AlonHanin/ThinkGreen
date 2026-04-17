<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/bootstrap.php';
require_method('POST');

$admin = require_admin_user($pdo);
$data = request_data();
require_fields($data, ['activity_id', 'action']);

$activityIdentifier = trim((string)$data['activity_id']);
$action = trim((string)$data['action']);
$reviewNotes = trim((string)($data['review_notes'] ?? ''));

if (!in_array($action, ['approve', 'reject'], true)) {
    respond_error('Action must be approve or reject.', 422);
}

$activityId = 0;
if (ctype_digit($activityIdentifier)) {
    $activityId = (int)$activityIdentifier;
} else {
    $lookup = $pdo->prepare('SELECT id FROM activities WHERE public_id = :public_id LIMIT 1');
    $lookup->execute([':public_id' => $activityIdentifier]);
    $activityId = (int)($lookup->fetch()['id'] ?? 0);
}

if ($activityId <= 0) {
    respond_error('Activity not found.', 404);
}

if ($action === 'approve') {
    $pdo->beginTransaction();
    try {
        $result = approve_activity_and_award($pdo, $activityId, (int)$admin['id'], $reviewNotes ?: null);
        $pdo->commit();
        respond_success([
            'message' => 'Activity approved successfully.',
            'result' => $result,
        ]);
    } catch (Throwable $e) {
        $pdo->rollBack();
        respond_error(APP_DEBUG ? $e->getMessage() : 'Failed to approve activity.', 500);
    }
}

$update = $pdo->prepare(
    'UPDATE activities
     SET status = "rejected",
         review_notes = :review_notes,
         reviewed_by = :reviewed_by,
         reviewed_at = UTC_TIMESTAMP(),
         updated_at = UTC_TIMESTAMP()
     WHERE id = :activity_id'
);
$update->execute([
    ':review_notes' => $reviewNotes ?: null,
    ':reviewed_by' => $admin['id'],
    ':activity_id' => $activityId,
]);

respond_success(['message' => 'Activity rejected successfully.']);
