<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/bootstrap.php';
require_method('POST');

$data = request_data();
require_fields($data, ['email', 'pin']);

$email = normalize_email((string)$data['email']);
$stmt = $pdo->prepare(
    'SELECT p.id
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
    ':pin' => trim((string)$data['pin']),
]);

if (!$stmt->fetch()) {
    respond_error('The security PIN is invalid or expired.', 422);
}

respond_success(['valid' => true]);
