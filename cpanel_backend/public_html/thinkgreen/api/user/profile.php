<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/bootstrap.php';
require_method('GET');

$user = require_auth_user($pdo);

respond_success([
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
