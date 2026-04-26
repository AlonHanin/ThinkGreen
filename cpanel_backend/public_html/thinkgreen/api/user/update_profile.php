<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/bootstrap.php';
require_method('POST');

$user = require_auth_user($pdo);
$data = request_data();
require_fields($data, ['full_name', 'email', 'phone']);

$email = normalize_email((string)$data['email']);
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    respond_error('Please enter a valid email address.', 422);
}

$exists = $pdo->prepare('SELECT id FROM users WHERE email = :email AND id <> :id LIMIT 1');
$exists->execute([
    ':email' => $email,
    ':id' => $user['id'],
]);
if ($exists->fetch()) {
    respond_error('Another account already uses this email.', 409);
}

$update = $pdo->prepare(
    'UPDATE users
     SET full_name = :full_name,
         email = :email,
         phone = :phone,
         date_of_birth = :date_of_birth,
         avatar_url = CASE
             WHEN :avatar_url_provided = 1 THEN :avatar_url
             ELSE avatar_url
         END,
         updated_at = UTC_TIMESTAMP()
     WHERE id = :id'
);
$avatarUrlProvided = array_key_exists('avatar_url', $data);
$avatarUrl = $avatarUrlProvided
    ? (trim((string)($data['avatar_url'] ?? '')) ?: null)
    : null;
$update->execute([
    ':full_name' => trim((string)$data['full_name']),
    ':email' => $email,
    ':phone' => trim((string)$data['phone']),
    ':date_of_birth' => trim((string)($data['date_of_birth'] ?? '')) ?: null,
    ':avatar_url_provided' => $avatarUrlProvided ? 1 : 0,
    ':avatar_url' => $avatarUrl,
    ':id' => $user['id'],
]);

$fresh = $pdo->prepare('SELECT * FROM users WHERE id = :id LIMIT 1');
$fresh->execute([':id' => $user['id']]);

respond_success(['user' => $fresh->fetch()]);
