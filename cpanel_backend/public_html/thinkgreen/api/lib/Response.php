<?php
declare(strict_types=1);

function respond_json(int $statusCode, array $payload): never
{
    http_response_code($statusCode);
    echo json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    exit;
}

function respond_success(array $data = [], int $statusCode = 200): never
{
    respond_json($statusCode, [
        'success' => true,
        'data' => $data,
    ]);
}

function respond_error(string $message, int $statusCode = 400, array $extra = []): never
{
    respond_json($statusCode, [
        'success' => false,
        'message' => $message,
        'errors' => $extra,
    ]);
}
