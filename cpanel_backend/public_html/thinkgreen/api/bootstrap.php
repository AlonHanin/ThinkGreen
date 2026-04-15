<?php
declare(strict_types=1);

require_once __DIR__ . '/config/cors.php';
require_once __DIR__ . '/config/config.php';
require_once __DIR__ . '/lib/Response.php';
require_once __DIR__ . '/lib/Helpers.php';
require_once __DIR__ . '/lib/Database.php';
require_once __DIR__ . '/lib/Auth.php';
require_once __DIR__ . '/lib/DomainService.php';

$pdo = Database::connection();
