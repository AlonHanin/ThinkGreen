<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/bootstrap.php';
require_method('POST');

$data = request_data();
$provider = strtolower(trim((string)($data['provider'] ?? '')));
$purpose = strtolower(trim((string)($data['purpose'] ?? '')));

if ($provider === '' || $purpose === '') {
    respond_error('Provider and purpose are required.', 422);
}

if (!oauth_provider_enabled($provider)) {
    respond_error('OAuth is not configured for this provider.', 503);
}

$userId = null;

if ($provider === 'google' && $purpose === 'login') {
    $request = oauth_create_request($pdo, null, 'google', 'login');
    respond_success([
        'provider' => 'google',
        'purpose' => 'login',
        'authorization_url' => oauth_google_authorize_url($request['state']),
    ]);
}

if ($provider === 'strava' && $purpose === 'connect') {
    $user = require_auth_user($pdo);
    $userId = (int)$user['id'];
    $request = oauth_create_request($pdo, $userId, 'strava', 'connect');

    respond_success([
        'provider' => 'strava',
        'purpose' => 'connect',
        'authorization_url' => oauth_strava_authorize_url($request['state']),
    ]);
}

respond_error('Unsupported OAuth flow.', 422);
