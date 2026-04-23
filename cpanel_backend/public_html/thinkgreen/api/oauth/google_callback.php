<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/bootstrap.php';

$state = trim((string)($_GET['state'] ?? ''));
$error = trim((string)($_GET['error'] ?? ''));
$errorDescription = trim((string)($_GET['error_description'] ?? ''));
$code = trim((string)($_GET['code'] ?? ''));

if ($state === '') {
    oauth_redirect_error('google', 'login', 'Missing Google OAuth state.', 'missing_state');
}

if ($error !== '') {
    oauth_redirect_error(
        'google',
        'login',
        $errorDescription !== '' ? $errorDescription : 'Google sign-in was cancelled.',
        $error
    );
}

if ($code === '') {
    oauth_redirect_error('google', 'login', 'Missing Google authorization code.', 'missing_code');
}

try {
    $handoffCode = oauth_google_complete($pdo, $state, $code);
    oauth_redirect_success('google', 'login', $handoffCode);
} catch (Throwable $exception) {
    error_log('Google OAuth callback failed: ' . $exception->getMessage());
    oauth_redirect_error('google', 'login', $exception->getMessage(), 'google_callback_failed');
}
