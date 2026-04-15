<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/bootstrap.php';
require_method('GET');

$user = require_auth_user($pdo);
$stmt = $pdo->prepare(
    'SELECT provider, external_user_id, connection_status, connected_at, last_synced_at
     FROM app_connections
     WHERE user_id = :user_id
     ORDER BY provider ASC'
);
$stmt->execute([':user_id' => $user['id']]);

respond_success(['connections' => $stmt->fetchAll()]);
