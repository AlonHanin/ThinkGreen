<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/bootstrap.php';
require_method('POST');
require_auth_user($pdo);
revoke_current_token($pdo);
respond_success(['message' => 'Logged out successfully.']);
