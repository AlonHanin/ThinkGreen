<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/bootstrap.php';
require_method('GET');

$user = require_auth_user($pdo);
$locale = user_locale($user);

$stmt = $pdo->prepare(
    'SELECT rr.id, rr.public_id, rr.redemption_code, rr.status, rr.redeemed_at, rr.used_at, rr.expires_at,
            r.public_id AS reward_public_id, r.title_en, r.title_he, r.description_en, r.description_he,
            r.points_cost, r.emoji, pb.name AS partner_name
     FROM reward_redemptions rr
     INNER JOIN rewards r ON r.id = rr.reward_id
     LEFT JOIN partner_businesses pb ON pb.id = r.partner_business_id
     WHERE rr.user_id = :user_id
     ORDER BY rr.redeemed_at DESC, rr.id DESC'
);
$stmt->execute([':user_id' => $user['id']]);
$rows = $stmt->fetchAll();

$redemptions = array_map(static function (array $row) use ($locale): array {
    return [
        'id' => (int)$row['id'],
        'public_id' => $row['public_id'],
        'redemption_code' => $row['redemption_code'],
        'status' => $row['status'],
        'redeemed_at' => $row['redeemed_at'],
        'used_at' => $row['used_at'],
        'expires_at' => $row['expires_at'],
        'reward' => [
            'public_id' => $row['reward_public_id'],
            'title' => localized_value($row, 'title', $locale),
            'description' => localized_value($row, 'description', $locale),
            'points_cost' => (int)$row['points_cost'],
            'emoji' => $row['emoji'],
            'partner_name' => $row['partner_name'],
        ],
        'qr_payload' => 'thinkgreen://reward/' . $row['redemption_code'] . '/' . $row['reward_public_id'],
    ];
}, $rows);

respond_success([
    'active_redemptions' => $redemptions,
    'available_points' => (int)$user['points_balance'],
]);
