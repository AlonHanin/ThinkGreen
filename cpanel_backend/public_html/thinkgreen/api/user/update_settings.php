<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/bootstrap.php';
require_method('POST');

$user = require_auth_user($pdo);
$data = request_data();

$locale = in_array(($data['locale'] ?? 'en'), ['en', 'he'], true) ? $data['locale'] : ($user['locale'] ?? 'en');
$notificationsEnabled = isset($data['notifications_enabled']) ? (int)((bool)$data['notifications_enabled']) : (int)$user['notifications_enabled'];
$darkMode = isset($data['dark_mode']) ? (int)((bool)$data['dark_mode']) : (int)$user['dark_mode'];
$locationServicesEnabled = isset($data['location_services_enabled']) ? (int)((bool)$data['location_services_enabled']) : (int)$user['location_services_enabled'];

$update = $pdo->prepare(
    'UPDATE users
     SET locale = :locale,
         notifications_enabled = :notifications_enabled,
         dark_mode = :dark_mode,
         location_services_enabled = :location_services_enabled,
         updated_at = UTC_TIMESTAMP()
     WHERE id = :id'
);
$update->execute([
    ':locale' => $locale,
    ':notifications_enabled' => $notificationsEnabled,
    ':dark_mode' => $darkMode,
    ':location_services_enabled' => $locationServicesEnabled,
    ':id' => $user['id'],
]);

respond_success([
    'message' => 'Settings updated successfully.',
    'locale' => $locale,
    'notifications_enabled' => (bool)$notificationsEnabled,
    'dark_mode' => (bool)$darkMode,
    'location_services_enabled' => (bool)$locationServicesEnabled,
]);
