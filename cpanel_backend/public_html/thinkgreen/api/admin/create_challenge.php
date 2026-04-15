<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/bootstrap.php';
require_method('POST');

$admin = require_admin_user($pdo);
$data = request_data();

$title = trim((string)($data['title'] ?? ''));
$description = trim((string)($data['description'] ?? ''));
$icon = trim((string)($data['icon'] ?? ''));
$pointsBonus = (int)($data['points_bonus'] ?? 0);
$targetCount = (int)($data['target_count'] ?? 0);
$endDateRaw = trim((string)($data['end_date'] ?? ''));
$linkedActivityTitle = trim((string)($data['linked_activity_title'] ?? ''));

if ($title === '') {
    respond_error('Challenge title is required.', 422);
}
if ($description === '') {
    $description = 'Custom eco challenge.';
}
if ($pointsBonus < 0) {
    respond_error('Points bonus must be zero or higher.', 422);
}
if ($targetCount <= 0) {
    respond_error('Target count must be at least 1.', 422);
}
if ($linkedActivityTitle === '') {
    respond_error('Linked activity title is required.', 422);
}

$endDate = null;
if ($endDateRaw !== '') {
    try {
        $endDate = (new DateTimeImmutable($endDateRaw))->setTimezone(new DateTimeZone('UTC'));
    } catch (Throwable $e) {
        respond_error('Invalid end date.', 422);
    }
}

$linkedActivity = resolve_activity_definition($pdo, $linkedActivityTitle);
if (!$linkedActivity) {
    respond_error('Unknown linked activity type.', 422);
}

$titleHe = trim((string)($data['title_he'] ?? ''));
$descriptionHe = trim((string)($data['description_he'] ?? ''));
$icon = $icon !== '' ? $icon : '🌱';

$slugBase = slugify($title);
$slug = ensure_unique_challenge_slug($pdo, $slugBase);
$sortOrder = next_challenge_sort_order($pdo);

$insert = $pdo->prepare(
    'INSERT INTO challenges
     (slug, title_en, title_he, description_en, description_he, icon, points_bonus, target_count,
      linked_activity_definition_id, end_date, is_active, sort_order, created_at)
     VALUES
     (:slug, :title_en, :title_he, :description_en, :description_he, :icon, :points_bonus, :target_count,
      :linked_activity_definition_id, :end_date, 1, :sort_order, UTC_TIMESTAMP())'
);
$insert->execute([
    ':slug' => $slug,
    ':title_en' => $title,
    ':title_he' => $titleHe !== '' ? $titleHe : $title,
    ':description_en' => $description,
    ':description_he' => $descriptionHe !== '' ? $descriptionHe : $description,
    ':icon' => $icon,
    ':points_bonus' => $pointsBonus,
    ':target_count' => $targetCount,
    ':linked_activity_definition_id' => (int)$linkedActivity['id'],
    ':end_date' => $endDate?->format('Y-m-d H:i:s'),
    ':sort_order' => $sortOrder,
]);

$challengeId = (int)$pdo->lastInsertId();

$stmt = $pdo->prepare(
    'SELECT c.id, c.slug, c.title_en, c.title_he, c.description_en, c.description_he, c.icon,
            c.points_bonus, c.target_count, c.end_date,
            ad.title_en AS linked_title_en, ad.title_he AS linked_title_he, ad.slug AS linked_slug
     FROM challenges c
     INNER JOIN activity_definitions ad ON ad.id = c.linked_activity_definition_id
     WHERE c.id = :id
     LIMIT 1'
);
$stmt->execute([':id' => $challengeId]);
$row = $stmt->fetch();

respond_success([
    'challenge' => [
        'id' => (int)$row['id'],
        'slug' => $row['slug'],
        'title' => $row['title_en'],
        'description' => $row['description_en'],
        'icon' => $row['icon'],
        'points_bonus' => (int)$row['points_bonus'],
        'target_count' => (int)$row['target_count'],
        'current_count' => 0,
        'progress' => 0,
        'is_completed' => false,
        'completed_at' => null,
        'reward_granted' => false,
        'reward_granted_at' => null,
        'end_date' => $row['end_date'],
        'linked_activity_slug' => $row['linked_slug'],
        'linked_activity_title' => $row['linked_title_en'],
    ],
    'created_by' => [
        'id' => (int)$admin['id'],
        'role' => $admin['role'],
    ],
]);

function resolve_activity_definition(PDO $pdo, string $title): ?array
{
    $normalized = strtolower(trim($title));

    $aliases = [
        'used public transport' => 'used_public_transport',
        'public transport' => 'used_public_transport',
        'recycled plastic bottles' => 'recycled_plastic_bottles',
        'recycle bottles' => 'recycled_plastic_bottles',
        'used a reusable bottle' => 'used_reusable_bottle',
        'reusable bottle' => 'used_reusable_bottle',
        'walked / biked to work' => 'walked_biked_to_work',
        'walked/biked to work' => 'walked_biked_to_work',
        'bike commute' => 'walked_biked_to_work',
    ];

    $slug = $aliases[$normalized] ?? slugify($title);
    $stmt = $pdo->prepare(
        'SELECT *
         FROM activity_definitions
         WHERE (slug = :slug OR title_en = :title OR title_he = :title)
           AND is_active = 1
         LIMIT 1'
    );
    $stmt->execute([
        ':slug' => $slug,
        ':title' => $title,
    ]);

    $definition = $stmt->fetch();
    return $definition ?: null;
}

function slugify(string $value): string
{
    $value = strtolower(trim($value));
    $value = preg_replace('/[^a-z0-9]+/', '_', $value) ?? '';
    $value = trim($value, '_');
    return $value !== '' ? $value : 'challenge';
}

function ensure_unique_challenge_slug(PDO $pdo, string $baseSlug): string
{
    $slug = $baseSlug;
    $suffix = 1;

    while (true) {
        $stmt = $pdo->prepare('SELECT id FROM challenges WHERE slug = :slug LIMIT 1');
        $stmt->execute([':slug' => $slug]);
        if (!$stmt->fetch()) {
            return $slug;
        }

        $suffix++;
        $slug = $baseSlug . '_' . $suffix;
    }
}

function next_challenge_sort_order(PDO $pdo): int
{
    $stmt = $pdo->query('SELECT COALESCE(MAX(sort_order), 0) + 1 AS next_sort_order FROM challenges');
    $row = $stmt->fetch();
    return (int)($row['next_sort_order'] ?? 1);
}
