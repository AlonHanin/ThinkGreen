<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/bootstrap.php';
require_method('POST');

$user = require_auth_user($pdo);
$data = request_data();
require_fields($data, ['provider']);

$provider = strtolower(trim((string)$data['provider']));
if ($provider !== 'strava') {
    respond_error('Unsupported provider.', 422);
}

$connection = oauth_disconnect_connection($pdo, (int)$user['id'], $provider);
respond_success([
    'connection' => $connection,
]);
