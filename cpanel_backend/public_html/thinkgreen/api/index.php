<?php
declare(strict_types=1);

require_once __DIR__ . '/bootstrap.php';

respond_success([
    'service' => 'Think Green API',
    'status' => 'ok',
    'time' => current_timestamp(),
    'endpoints' => [
        'auth/login.php',
        'auth/signup.php',
        'activities/list.php',
        'admin/pending_activities.php',
        'rewards/catalog.php',
    ],
]);
