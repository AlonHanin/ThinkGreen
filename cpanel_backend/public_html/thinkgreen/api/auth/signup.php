<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/bootstrap.php';
require_method('POST');

$data = request_data();
require_fields($data, ['full_name', 'email', 'phone', 'date_of_birth', 'password', 'confirm_password']);

$fullName = trim((string)($data['full_name'] ?? ''));
$email = normalize_email((string)($data['email'] ?? ''));
$phone = trim((string)($data['phone'] ?? ''));
$password = (string)($data['password'] ?? '');
$confirmPassword = (string)($data['confirm_password'] ?? '');
$locale = in_array(($data['locale'] ?? 'en'), ['he', 'en'], true) ? (string)$data['locale'] : 'en';
$dateOfBirthRaw = trim((string)($data['date_of_birth'] ?? ''));

if (mb_strlen($fullName) < 2) {
    respond_error('Full name must contain at least 2 characters.', 422);
}

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    respond_error('Please enter a valid email address.', 422);
}

if ($password !== $confirmPassword) {
    respond_error('Passwords do not match.', 422);
}

if (mb_strlen($password) < 6) {
    respond_error('Password must contain at least 6 characters.', 422);
}

/**
 * Accept both:
 * - DD/MM/YYYY
 * - YYYY-MM-DD
 * Always save to DB as YYYY-MM-DD
 */
$dateOfBirth = null;

if (preg_match('/^\d{2}\/\d{2}\/\d{4}$/', $dateOfBirthRaw) === 1) {
    $dateOfBirth = DateTime::createFromFormat('d/m/Y', $dateOfBirthRaw);
} elseif (preg_match('/^\d{4}-\d{2}-\d{2}$/', $dateOfBirthRaw) === 1) {
    $dateOfBirth = DateTime::createFromFormat('Y-m-d', $dateOfBirthRaw);
}

if (!$dateOfBirth) {
    respond_error('Date of birth must be in DD/MM/YYYY or YYYY-MM-DD format.', 422);
}

$dateErrors = DateTime::getLastErrors();
if (($dateErrors['warning_count'] ?? 0) > 0 || ($dateErrors['error_count'] ?? 0) > 0) {
    respond_error('Please enter a valid date of birth.', 422);
}

$dateOfBirthForDb = $dateOfBirth->format('Y-m-d');

$exists = $pdo->prepare('SELECT id FROM users WHERE email = :email LIMIT 1');
$exists->execute([':email' => $email]);

if ($exists->fetch()) {
    respond_error('An account with this email already exists.', 409);
}

try {
    $insert = $pdo->prepare(
        'INSERT INTO users
         (public_id, full_name, email, phone, date_of_birth, password_hash, role, locale, created_at, updated_at)
         VALUES
         (:public_id, :full_name, :email, :phone, :date_of_birth, :password_hash, "user", :locale, UTC_TIMESTAMP(), UTC_TIMESTAMP())'
    );

    $insert->execute([
        ':public_id' => generate_public_id('TG'),
        ':full_name' => $fullName,
        ':email' => $email,
        ':phone' => $phone,
        ':date_of_birth' => $dateOfBirthForDb,
        ':password_hash' => password_hash($password, PASSWORD_DEFAULT),
        ':locale' => $locale,
    ]);

    $userId = (int)$pdo->lastInsertId();
    $token = issue_auth_token($pdo, $userId);

    $userStmt = $pdo->prepare(
        'SELECT id, public_id, full_name, email, phone, date_of_birth, avatar_url, role, locale,
                notifications_enabled, dark_mode, location_services_enabled, points_balance
         FROM users WHERE id = :id LIMIT 1'
    );
    $userStmt->execute([':id' => $userId]);

    respond_success([
        'token' => $token,
        'user' => $userStmt->fetch(),
    ], 201);
} catch (Throwable $e) {
    error_log('Signup failed: ' . $e->getMessage());
    respond_error('Signup failed on server.', 500);
}