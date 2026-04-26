<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/bootstrap.php';
require_method('POST');

$user = require_auth_user($pdo);
$upload = upload_profile_image($_FILES['avatar'] ?? []);

if ($upload === null) {
    respond_error('Please attach an image first.', 422);
}

$update = $pdo->prepare(
    'UPDATE users
     SET avatar_url = :avatar_url,
         updated_at = UTC_TIMESTAMP()
     WHERE id = :id'
);
$update->execute([
    ':avatar_url' => $upload['image_url'],
    ':id' => $user['id'],
]);

$fresh = $pdo->prepare('SELECT * FROM users WHERE id = :id LIMIT 1');
$fresh->execute([':id' => $user['id']]);

respond_success([
    'user' => $fresh->fetch(),
    'upload' => $upload,
]);
