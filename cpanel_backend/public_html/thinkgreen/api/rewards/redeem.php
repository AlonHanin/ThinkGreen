<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/bootstrap.php';
require_method('POST');

$user = require_auth_user($pdo);
$data = request_data();
require_fields($data, ['reward_public_id']);

$stmt = $pdo->prepare(
    'SELECT r.id, r.public_id, r.points_cost
     FROM rewards r
     WHERE r.public_id = :public_id
       AND r.is_active = 1
     LIMIT 1'
);
$stmt->execute([':public_id' => trim((string)$data['reward_public_id'])]);
$reward = $stmt->fetch();

if (!$reward) {
    respond_error('Reward not found.', 404);
}

refresh_user_points($pdo, (int)$user['id']);
$fresh = $pdo->prepare('SELECT points_balance FROM users WHERE id = :id LIMIT 1');
$fresh->execute([':id' => $user['id']]);
$currentBalance = (int)($fresh->fetch()['points_balance'] ?? 0);

if ($currentBalance < (int)$reward['points_cost']) {
    respond_error('Not enough points to redeem this reward.', 422);
}

$pdo->beginTransaction();
try {
    $publicId = generate_public_id('RDM');
    $redemptionCode = generate_redemption_code();

    $insert = $pdo->prepare(
        'INSERT INTO reward_redemptions
         (public_id, user_id, reward_id, redemption_code, status, redeemed_at)
         VALUES (:public_id, :user_id, :reward_id, :redemption_code, "active", UTC_TIMESTAMP())'
    );
    $insert->execute([
        ':public_id' => $publicId,
        ':user_id' => $user['id'],
        ':reward_id' => $reward['id'],
        ':redemption_code' => $redemptionCode,
    ]);

    $redemptionId = (int)$pdo->lastInsertId();

    upsert_points_event(
        $pdo,
        (int)$user['id'],
        -1 * (int)$reward['points_cost'],
        'reward_redeemed',
        'reward_redemption',
        $redemptionId,
        'Reward redeemed'
    );

    $newBalance = refresh_user_points($pdo, (int)$user['id']);
    $pdo->commit();

    respond_success([
        'message' => 'Reward redeemed successfully.',
        'redemption_id' => $redemptionId,
        'redemption_code' => $redemptionCode,
        'points_balance' => $newBalance,
    ], 201);
} catch (Throwable $e) {
    $pdo->rollBack();
    respond_error(APP_DEBUG ? $e->getMessage() : 'Failed to redeem reward.', 500);
}
