<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/bootstrap.php';
require_method('GET');

$user = require_auth_user($pdo);
sync_user_challenges($pdo, (int)$user['id']);
$freshUser = $pdo->prepare('SELECT * FROM users WHERE id = :id LIMIT 1');
$freshUser->execute([':id' => $user['id']]);
$user = $freshUser->fetch();
$locale = user_locale($user);

$stmt = $pdo->prepare(
    'SELECT c.id, c.slug, c.title_en, c.title_he, c.description_en, c.description_he, c.icon,
            c.points_bonus, c.target_count, c.end_date,
            ad.title_en AS linked_title_en, ad.title_he AS linked_title_he, ad.slug AS linked_slug,
            uc.current_count, uc.is_completed, uc.completed_at, uc.reward_granted, uc.reward_granted_at
     FROM challenges c
     INNER JOIN activity_definitions ad ON ad.id = c.linked_activity_definition_id
     LEFT JOIN user_challenges uc ON uc.challenge_id = c.id AND uc.user_id = :user_id
     WHERE c.is_active = 1
     ORDER BY c.sort_order ASC, c.id ASC'
);
$stmt->execute([':user_id' => $user['id']]);
$rows = $stmt->fetchAll();

$challenges = array_map(static function (array $row) use ($locale): array {
    $currentCount = (int)($row['current_count'] ?? 0);
    $targetCount = (int)$row['target_count'];
    return [
        'id' => (int)$row['id'],
        'slug' => $row['slug'],
        'title' => localized_value($row, 'title', $locale),
        'description' => localized_value($row, 'description', $locale),
        'icon' => $row['icon'],
        'points_bonus' => (int)$row['points_bonus'],
        'target_count' => $targetCount,
        'current_count' => $currentCount,
        'progress' => $targetCount > 0 ? min($currentCount / $targetCount, 1.0) : 0,
        'is_completed' => (bool)($row['is_completed'] ?? 0),
        'completed_at' => $row['completed_at'],
        'reward_granted' => (bool)($row['reward_granted'] ?? 0),
        'reward_granted_at' => $row['reward_granted_at'],
        'end_date' => $row['end_date'],
        'linked_activity_slug' => $row['linked_slug'],
        'linked_activity_title' => $locale === 'he' ? $row['linked_title_he'] : $row['linked_title_en'],
    ];
}, $rows);

respond_success([
    'challenges' => $challenges,
    'points_balance' => (int)$user['points_balance'],
]);
