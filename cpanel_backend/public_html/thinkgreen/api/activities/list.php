<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/bootstrap.php';
require_method('GET');

$user = require_auth_user($pdo);
$locale = user_locale($user);

$stmt = $pdo->prepare(
    'SELECT a.id, a.public_id, a.title_snapshot, a.source, a.activity_datetime, a.status, a.points_awarded,
            a.image_path, a.client_verified, a.review_notes, a.reviewed_at, a.created_at,
            ad.slug AS activity_slug, ad.title_en, ad.title_he
     FROM activities a
     LEFT JOIN activity_definitions ad ON ad.id = a.activity_definition_id
     WHERE a.user_id = :user_id
     ORDER BY a.activity_datetime DESC, a.id DESC'
);
$stmt->execute([':user_id' => $user['id']]);
$rows = $stmt->fetchAll();

$activities = array_map(static function (array $row) use ($locale): array {
    return [
        'id' => (int)$row['id'],
        'public_id' => $row['public_id'],
        'activity_slug' => $row['activity_slug'],
        'title' => $row['title_snapshot'] ?: localized_value($row, 'title', $locale),
        'source' => $row['source'],
        'activity_datetime' => $row['activity_datetime'],
        'status' => $row['status'],
        'points' => (int)$row['points_awarded'],
        'image_url' => $row['image_path'] ? APP_BASE_URL . $row['image_path'] : null,
        'client_verified' => (bool)$row['client_verified'],
        'review_notes' => $row['review_notes'],
        'reviewed_at' => $row['reviewed_at'],
        'created_at' => $row['created_at'],
    ];
}, $rows);

respond_success([
    'activities' => $activities,
    'points_balance' => (int)$user['points_balance'],
]);
