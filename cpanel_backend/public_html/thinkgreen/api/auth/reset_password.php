<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/bootstrap.php';
require_method('POST');

$data = request_data();
require_fields($data, ['email', 'pin', 'new_password', 'confirm_password']);

if ((string)$data['new_password'] !== (string)$data['confirm_password']) {
    respond_error('Passwords do not match.', 422);
}
if (mb_strlen((string)$data['new_password']) < 6) {
    respond_error('Password must contain at least 6 characters.', 422);
}

$email = normalize_email((string)$data['email']);
$pin = trim((string)$data['pin']);

$stmt = $pdo->prepare(
    'SELECT p.id AS pin_id, u.id AS user_id
     FROM password_reset_pins p
     INNER JOIN users u ON u.id = p.user_id
     WHERE u.email = :email
       AND p.pin_code = :pin
       AND p.used_at IS NULL
       AND p.expires_at > UTC_TIMESTAMP()
     ORDER BY p.id DESC
     LIMIT 1'
);
$stmt->execute([
    ':email' => $email,
    ':pin' => $pin,
]);
$row = $stmt->fetch();

if (!$row) {
    respond_error('The security PIN is invalid or expired.', 422);
}

$updateUser = $pdo->prepare('UPDATE users SET password_hash = :password_hash, updated_at = UTC_TIMESTAMP() WHERE id = :user_id');
$updateUser->execute([
    ':password_hash' => password_hash((string)$data['new_password'], PASSWORD_DEFAULT),
    ':user_id' => $row['user_id'],
]);

$markUsed = $pdo->prepare('UPDATE password_reset_pins SET used_at = UTC_TIMESTAMP() WHERE id = :pin_id');
$markUsed->execute([':pin_id' => $row['pin_id']]);

respond_success(['message' => 'Password updated successfully.']);
