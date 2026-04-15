<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/bootstrap.php';
require_method('GET');

$user = require_auth_user($pdo);
$locale = user_locale($user);

$activities = $pdo->query(
    'SELECT slug, title_en, title_he, description_en, description_he, default_points, default_source
     FROM activity_definitions
     WHERE is_active = 1
     ORDER BY sort_order ASC, id ASC'
)->fetchAll();

$activityDefinitions = array_map(static function (array $row) use ($locale): array {
    return [
        'slug' => $row['slug'],
        'title' => localized_value($row, 'title', $locale),
        'description' => localized_value($row, 'description', $locale),
        'default_points' => (int)$row['default_points'],
        'default_source' => $row['default_source'],
    ];
}, $activities);

respond_success([
    'activity_definitions' => $activityDefinitions,
    'locale' => $locale,
]);
