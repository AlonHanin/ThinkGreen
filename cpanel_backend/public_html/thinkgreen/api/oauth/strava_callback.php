<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/bootstrap.php';

$state = trim((string)($_GET['state'] ?? ''));
$error = trim((string)($_GET['error'] ?? ''));
$code = trim((string)($_GET['code'] ?? ''));

if ($state === '') {
    oauth_redirect_error('strava', 'connect', 'Missing Strava OAuth state.', 'missing_state');
}

if ($error !== '') {
    oauth_redirect_error('strava', 'connect', 'Strava connection was cancelled.', $error);
}

if ($code === '') {
    oauth_redirect_error('strava', 'connect', 'Missing Strava authorization code.', 'missing_code');
}

try {
    $handoffCode = oauth_strava_complete($pdo, $state, $code);
    oauth_redirect_success('strava', 'connect', $handoffCode);
} catch (Throwable $exception) {
    error_log('Strava OAuth callback failed: ' . $exception->getMessage());
    oauth_redirect_error('strava', 'connect', $exception->getMessage(), 'strava_callback_failed');
}
