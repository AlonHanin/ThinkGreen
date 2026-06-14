<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/bootstrap.php';

$admin = require_admin_user($pdo);
$method = strtoupper($_SERVER['REQUEST_METHOD'] ?? 'GET');

if ($method === 'GET') {
    respond_success(['rewards' => fetch_admin_rewards($pdo)]);
}

$data = request_data();
$publicId = trim((string)($data['reward_public_id'] ?? ''));

if ($method === 'DELETE') {
    if ($publicId === '') {
        respond_error('Reward public id is required.', 422);
    }

    $stmt = $pdo->prepare('UPDATE rewards SET is_active = 0 WHERE public_id = :public_id AND is_active = 1');
    $stmt->execute([':public_id' => $publicId]);
    if ($stmt->rowCount() === 0) {
        respond_error('Active reward not found.', 404);
    }

    respond_success(['message' => 'Reward removed successfully.']);
}

if ($method !== 'POST' && $method !== 'PUT') {
    respond_error('Method not allowed.', 405);
}

$title = trim((string)($data['title'] ?? ''));
$description = trim((string)($data['description'] ?? ''));
$emoji = trim((string)($data['emoji'] ?? ''));
$partnerName = trim((string)($data['partner_name'] ?? ''));
$pointsCost = (int)($data['points_cost'] ?? -1);

if ($title === '') {
    respond_error('Reward title is required.', 422);
}
if ($pointsCost < 0) {
    respond_error('Points cost must be zero or higher.', 422);
}
if ($method === 'PUT' && $publicId === '') {
    respond_error('Reward public id is required.', 422);
}

$partnerId = resolve_partner_business_id($pdo, $partnerName);

if ($method === 'POST') {
    $stmt = $pdo->prepare(
        'INSERT INTO rewards
         (public_id, partner_business_id, title_en, title_he, description_en, description_he,
          points_cost, emoji, is_active, sort_order, created_at)
         VALUES
         (:public_id, :partner_business_id, :title, :title, :description, :description,
          :points_cost, :emoji, 1, :sort_order, UTC_TIMESTAMP())'
    );
    $publicId = generate_public_id('RWD');
    $stmt->execute([
        ':public_id' => $publicId,
        ':partner_business_id' => $partnerId,
        ':title' => $title,
        ':description' => $description,
        ':points_cost' => $pointsCost,
        ':emoji' => $emoji !== '' ? $emoji : null,
        ':sort_order' => next_reward_sort_order($pdo),
    ]);
} else {
    $stmt = $pdo->prepare(
        'UPDATE rewards
         SET partner_business_id = :partner_business_id,
             title_en = :title,
             description_en = :description,
             points_cost = :points_cost,
             emoji = :emoji,
             is_active = 1
         WHERE public_id = :public_id'
    );
    $stmt->execute([
        ':partner_business_id' => $partnerId,
        ':title' => $title,
        ':description' => $description,
        ':points_cost' => $pointsCost,
        ':emoji' => $emoji !== '' ? $emoji : null,
        ':public_id' => $publicId,
    ]);
    if ($stmt->rowCount() === 0 && !reward_exists($pdo, $publicId)) {
        respond_error('Reward not found.', 404);
    }
}

$reward = fetch_admin_reward($pdo, $publicId);
respond_success([
    'reward' => $reward,
    'updated_by' => [
        'id' => (int)$admin['id'],
        'role' => $admin['role'],
    ],
], $method === 'POST' ? 201 : 200);

function fetch_admin_rewards(PDO $pdo): array
{
    $stmt = $pdo->query(
        'SELECT r.public_id, r.title_en AS title, r.description_en AS description,
                r.points_cost, r.emoji, r.is_active, r.sort_order, pb.name AS partner_name
         FROM rewards r
         LEFT JOIN partner_businesses pb ON pb.id = r.partner_business_id
         ORDER BY r.is_active DESC, r.sort_order ASC, r.id ASC'
    );
    return array_map('format_admin_reward', $stmt->fetchAll());
}

function fetch_admin_reward(PDO $pdo, string $publicId): array
{
    $stmt = $pdo->prepare(
        'SELECT r.public_id, r.title_en AS title, r.description_en AS description,
                r.points_cost, r.emoji, r.is_active, r.sort_order, pb.name AS partner_name
         FROM rewards r
         LEFT JOIN partner_businesses pb ON pb.id = r.partner_business_id
         WHERE r.public_id = :public_id
         LIMIT 1'
    );
    $stmt->execute([':public_id' => $publicId]);
    $reward = $stmt->fetch();
    if (!$reward) {
        respond_error('Reward not found.', 404);
    }
    return format_admin_reward($reward);
}

function format_admin_reward(array $row): array
{
    return [
        'public_id' => $row['public_id'],
        'title' => $row['title'],
        'description' => $row['description'] ?? '',
        'points_cost' => (int)$row['points_cost'],
        'emoji' => $row['emoji'] ?? '',
        'partner_name' => $row['partner_name'] ?? '',
        'is_active' => (bool)$row['is_active'],
        'sort_order' => (int)$row['sort_order'],
    ];
}

function resolve_partner_business_id(PDO $pdo, string $name): ?int
{
    if ($name === '') {
        return null;
    }

    $find = $pdo->prepare('SELECT id FROM partner_businesses WHERE name = :name LIMIT 1');
    $find->execute([':name' => $name]);
    $existing = $find->fetch();
    if ($existing) {
        return (int)$existing['id'];
    }

    $insert = $pdo->prepare(
        'INSERT INTO partner_businesses (name, rewards_text, is_active, sort_order, created_at)
         VALUES (:name, :rewards_text, 1, :sort_order, UTC_TIMESTAMP())'
    );
    $insert->execute([
        ':name' => $name,
        ':rewards_text' => 'Rewards and benefits',
        ':sort_order' => next_partner_sort_order($pdo),
    ]);
    return (int)$pdo->lastInsertId();
}

function reward_exists(PDO $pdo, string $publicId): bool
{
    $stmt = $pdo->prepare('SELECT id FROM rewards WHERE public_id = :public_id LIMIT 1');
    $stmt->execute([':public_id' => $publicId]);
    return (bool)$stmt->fetch();
}

function next_reward_sort_order(PDO $pdo): int
{
    return (int)$pdo->query('SELECT COALESCE(MAX(sort_order), 0) + 1 FROM rewards')->fetchColumn();
}

function next_partner_sort_order(PDO $pdo): int
{
    return (int)$pdo->query('SELECT COALESCE(MAX(sort_order), 0) + 1 FROM partner_businesses')->fetchColumn();
}
