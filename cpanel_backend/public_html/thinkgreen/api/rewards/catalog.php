<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/bootstrap.php';
require_method('GET');

$user = require_auth_user($pdo);
$locale = user_locale($user);

$stmt = $pdo->query(
    'SELECT r.id, r.public_id, r.title_en, r.title_he, r.description_en, r.description_he,
            r.points_cost, r.emoji, pb.name AS partner_name
     FROM rewards r
     LEFT JOIN partner_businesses pb ON pb.id = r.partner_business_id
     WHERE r.is_active = 1
     ORDER BY r.sort_order ASC, r.id ASC'
);
$rows = $stmt->fetchAll();

$rewards = array_map(static function (array $row) use ($locale): array {
    return [
        'id' => (int)$row['id'],
        'public_id' => $row['public_id'],
        'title' => localized_value($row, 'title', $locale),
        'description' => localized_value($row, 'description', $locale),
        'points_cost' => (int)$row['points_cost'],
        'emoji' => $row['emoji'],
        'partner_name' => $row['partner_name'],
    ];
}, $rows);

respond_success([
    'rewards' => $rewards,
    'available_points' => (int)$user['points_balance'],
]);
