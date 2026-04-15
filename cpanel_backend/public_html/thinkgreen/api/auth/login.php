<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/bootstrap.php';
require_method('POST');

$data = request_data();
require_fields($data, ['email', 'password']);

$email = normalize_email((string)$data['email']);
$stmt = $pdo->prepare('SELECT * FROM users WHERE email = :email LIMIT 1');
$stmt->execute([':email' => $email]);
$user = $stmt->fetch();

if (!$user || !password_verify((string)$data['password'], (string)$user['password_hash'])) {
    respond_error('Invalid email or password.', 401);
}

$token = issue_auth_token($pdo, (int)$user['id']);

respond_success([
    'token' => $token,
    'user' => [
        'id' => (int)$user['id'],
        'public_id' => $user['public_id'],
        'full_name' => $user['full_name'],
        'email' => $user['email'],
        'phone' => $user['phone'],
        'date_of_birth' => $user['date_of_birth'],
        'avatar_url' => $user['avatar_url'],
        'role' => $user['role'],
        'locale' => $user['locale'],
        'notifications_enabled' => (bool)$user['notifications_enabled'],
        'dark_mode' => (bool)$user['dark_mode'],
        'location_services_enabled' => (bool)$user['location_services_enabled'],
        'points_balance' => (int)$user['points_balance'],
    ],
]);
