<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/bootstrap.php';
require_method('GET');

$user = require_auth_user($pdo);
$stmt = $pdo->prepare(
    'SELECT id, title, body, type, is_read, metadata_json, created_at
     FROM notifications
     WHERE user_id = :user_id
     ORDER BY created_at DESC, id DESC'
);
$stmt->execute([':user_id' => $user['id']]);
$rows = $stmt->fetchAll();

$notifications = array_map(static function (array $row): array {
    return [
        'id' => (int)$row['id'],
        'title' => $row['title'],
        'body' => $row['body'],
        'type' => $row['type'],
        'is_read' => (bool)$row['is_read'],
        'metadata' => $row['metadata_json'] ? json_decode($row['metadata_json'], true) : null,
        'created_at' => $row['created_at'],
    ];
}, $rows);

respond_success(['notifications' => $notifications]);
