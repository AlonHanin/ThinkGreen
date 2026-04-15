<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/bootstrap.php';
require_method('GET');

respond_success([
    'service' => 'Think Green API',
    'status' => 'healthy',
    'time' => current_timestamp(),
    'php_version' => PHP_VERSION,
]);
