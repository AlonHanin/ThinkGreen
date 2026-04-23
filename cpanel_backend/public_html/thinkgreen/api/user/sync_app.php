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

try {
    $summary = oauth_sync_strava_activities($pdo, (int)$user['id']);
    $connection = oauth_connection_payload(oauth_get_app_connection($pdo, (int)$user['id'], 'strava'));

    respond_success([
        'provider' => 'strava',
        'connection' => $connection,
        'sync_summary' => $summary,
    ]);
} catch (Throwable $exception) {
    respond_error($exception->getMessage(), 400);
}
