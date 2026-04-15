<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/bootstrap.php';
require_method('GET');

require_auth_user($pdo);

$stmt = $pdo->query(
    'SELECT id, name, rewards_text, location_text
     FROM partner_businesses
     WHERE is_active = 1
     ORDER BY sort_order ASC, id ASC'
);

respond_success(['partner_businesses' => $stmt->fetchAll()]);
