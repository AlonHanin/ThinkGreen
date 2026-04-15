<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/bootstrap.php';
require_method('GET');

$admin = require_admin_user($pdo);
$locale = user_locale($admin);

$stmt = $pdo->query(
    'SELECT a.id, a.public_id, a.title_snapshot, a.source, a.activity_datetime, a.status, a.points_awarded,
            a.image_path, a.client_verified, a.review_notes, a.created_at,
            ad.slug AS activity_slug, ad.title_en, ad.title_he,
            u.public_id AS user_public_id, u.full_name AS user_name, u.email AS user_email
     FROM activities a
     INNER JOIN users u ON u.id = a.user_id
     LEFT JOIN activity_definitions ad ON ad.id = a.activity_definition_id
     WHERE a.status = "pending"
     ORDER BY a.created_at ASC, a.id ASC'
);
$rows = $stmt->fetchAll();

$activities = array_map(static function (array $row) use ($locale): array {
    return [
        'id' => (int)$row['id'],
        'public_id' => $row['public_id'],
        'user_public_id' => $row['user_public_id'],
        'user_name' => $row['user_name'],
        'user_email' => $row['user_email'],
        'activity_slug' => $row['activity_slug'],
        'title' => $row['title_snapshot'] ?: localized_value($row, 'title', $locale),
        'source' => $row['source'],
        'activity_datetime' => $row['activity_datetime'],
        'status' => $row['status'],
        'points' => (int)$row['points_awarded'],
        'image_url' => $row['image_path'] ? APP_BASE_URL . $row['image_path'] : null,
        'client_verified' => (bool)$row['client_verified'],
        'review_notes' => $row['review_notes'],
        'created_at' => $row['created_at'],
    ];
}, $rows);

respond_success(['pending_activities' => $activities]);
