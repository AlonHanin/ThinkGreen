<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/bootstrap.php';
require_method('POST');

$data = request_data();
require_fields($data, ['handoff_code']);

$payload = oauth_consume_result($pdo, trim((string)$data['handoff_code']));
respond_success($payload);
