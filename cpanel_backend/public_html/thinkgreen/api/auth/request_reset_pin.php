<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/bootstrap.php';
require_method('POST');

$data = request_data();
require_fields($data, ['email']);

$email = normalize_email((string)$data['email']);
$stmt = $pdo->prepare('SELECT id, email FROM users WHERE email = :email LIMIT 1');
$stmt->execute([':email' => $email]);
$user = $stmt->fetch();

if (!$user) {
    respond_error('No account was found for this email.', 404);
}

$pin = generate_pin(4);

$invalidate = $pdo->prepare('UPDATE password_reset_pins SET used_at = UTC_TIMESTAMP() WHERE user_id = :user_id AND used_at IS NULL');
$invalidate->execute([':user_id' => $user['id']]);

$insert = $pdo->prepare(
    'INSERT INTO password_reset_pins (user_id, pin_code, expires_at, created_at)
     VALUES (:user_id, :pin_code, DATE_ADD(UTC_TIMESTAMP(), INTERVAL :ttl MINUTE), UTC_TIMESTAMP())'
);
$insert->bindValue(':user_id', (int)$user['id'], PDO::PARAM_INT);
$insert->bindValue(':pin_code', $pin, PDO::PARAM_STR);
$insert->bindValue(':ttl', RESET_PIN_TTL_MINUTES, PDO::PARAM_INT);
$insert->execute();

/**
 * In production, email the PIN instead of returning it.
 * For the college project / staging, returning the PIN is convenient for testing.
 */
respond_success([
    'message' => 'Security PIN generated successfully.',
    'demo_pin' => APP_DEBUG ? $pin : null,
]);
