<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/bootstrap.php';
require_method('POST');

$user = require_auth_user($pdo);
$data = request_data();

$definitionSlug = trim((string)($data['activity_definition_slug'] ?? ''));
$title = trim((string)($data['title'] ?? ''));
$source = trim((string)($data['source'] ?? 'manual'));
$activityDateTime = trim((string)($data['activity_datetime'] ?? ''));
$clientVerified = !empty($data['client_verified']);
$requestedStatus = trim((string)($data['status'] ?? 'pending'));
$reviewStatus = ($clientVerified && $requestedStatus === 'approved') ? 'approved' : 'pending';

if (!in_array($source, ['manual', 'strava', 'moovit'], true)) {
    respond_error('Invalid source.', 422);
}
if ($activityDateTime === '') {
    respond_error('Activity date/time is required.', 422);
}

$definition = null;
if ($definitionSlug !== '') {
    $stmt = $pdo->prepare('SELECT * FROM activity_definitions WHERE slug = :slug AND is_active = 1 LIMIT 1');
    $stmt->execute([':slug' => $definitionSlug]);
    $definition = $stmt->fetch();
} elseif ($title !== '') {
    $stmt = $pdo->prepare(
        'SELECT * FROM activity_definitions
         WHERE (title_en = :title OR title_he = :title)
           AND is_active = 1
         LIMIT 1'
    );
    $stmt->execute([':title' => $title]);
    $definition = $stmt->fetch();
}

if (!$definition) {
    respond_error('Unknown activity type.', 422);
}

$upload = isset($_FILES['image']) ? upload_activity_image($_FILES['image']) : null;
$publicId = generate_public_id('ACT');

$insert = $pdo->prepare(
    'INSERT INTO activities
     (public_id, user_id, activity_definition_id, title_snapshot, source, activity_datetime, status, points_awarded,
      image_path, image_mime, image_original_name, ai_tags_json, client_verified, created_at, updated_at)
     VALUES
     (:public_id, :user_id, :activity_definition_id, :title_snapshot, :source, :activity_datetime, :status, :points_awarded,
      :image_path, :image_mime, :image_original_name, :ai_tags_json, :client_verified, UTC_TIMESTAMP(), UTC_TIMESTAMP())'
);
$insert->execute([
    ':public_id' => $publicId,
    ':user_id' => $user['id'],
    ':activity_definition_id' => $definition['id'],
    ':title_snapshot' => localized_value($definition, 'title', user_locale($user)),
    ':source' => $source,
    ':activity_datetime' => $activityDateTime,
    ':status' => $reviewStatus,
    ':points_awarded' => (int)$definition['default_points'],
    ':image_path' => $upload['image_path'] ?? null,
    ':image_mime' => $upload['image_mime'] ?? null,
    ':image_original_name' => $upload['image_original_name'] ?? null,
    ':ai_tags_json' => isset($data['ai_tags']) ? json_encode($data['ai_tags'], JSON_UNESCAPED_UNICODE) : null,
    ':client_verified' => $clientVerified ? 1 : 0,
]);

$activityId = (int)$pdo->lastInsertId();
if ($reviewStatus === 'approved') {
    upsert_points_event(
        $pdo,
        (int)$user['id'],
        (int)$definition['default_points'],
        'activity_approved',
        'activity',
        $activityId,
        'Client verified activity'
    );
    sync_user_challenges($pdo, (int)$user['id']);
}

$newBalance = refresh_user_points($pdo, (int)$user['id']);

respond_success([
    'activity_id' => $activityId,
    'public_id' => $publicId,
    'status' => $reviewStatus,
    'points_balance' => $newBalance,
]);
