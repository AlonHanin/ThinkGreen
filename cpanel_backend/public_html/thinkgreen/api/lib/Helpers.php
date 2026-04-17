<?php
declare(strict_types=1);

function require_method(string $method): void
{
    if (strtoupper($_SERVER['REQUEST_METHOD'] ?? '') !== strtoupper($method)) {
        respond_error('Method not allowed.', 405);
    }
}

function request_data(): array
{
    $contentType = $_SERVER['CONTENT_TYPE'] ?? '';

    if (stripos($contentType, 'application/json') !== false) {
        $raw = file_get_contents('php://input');
        $decoded = json_decode($raw ?: '{}', true);
        return is_array($decoded) ? $decoded : [];
    }

    return $_POST;
}

function require_fields(array $data, array $fields): void
{
    $missing = [];
    foreach ($fields as $field) {
        if (!array_key_exists($field, $data) || trim((string) $data[$field]) === '') {
            $missing[] = $field;
        }
    }

    if ($missing !== []) {
        respond_error('Missing required fields.', 422, ['missing' => $missing]);
    }
}

function normalize_email(string $email): string
{
    return strtolower(trim($email));
}

function generate_public_id(string $prefix = 'TG'): string
{
    return $prefix . '-' . time() . '-' . bin2hex(random_bytes(3));
}

function generate_redemption_code(): string
{
    return 'TG-' . strtoupper(bin2hex(random_bytes(3)));
}

function generate_pin(int $digits = 4): string
{
    $min = 10 ** ($digits - 1);
    $max = (10 ** $digits) - 1;
    return (string) random_int($min, $max);
}

function user_locale(array $user): string
{
    return ($user['locale'] ?? 'en') === 'he' ? 'he' : 'en';
}

function localized_value(array $row, string $base, string $locale): string
{
    $preferredKey = $locale === 'he' ? "{$base}_he" : "{$base}_en";
    $fallbackKey = $locale === 'he' ? "{$base}_en" : "{$base}_he";
    return (string) ($row[$preferredKey] ?? $row[$fallbackKey] ?? '');
}

function ensure_directory(string $path): void
{
    if (!is_dir($path) && !mkdir($path, 0755, true) && !is_dir($path)) {
        respond_error('Failed to create upload directory.', 500);
    }
}

function detect_uploaded_mime_type(array $file): string
{
    $tmpName = (string)($file['tmp_name'] ?? '');
    if ($tmpName !== '' && function_exists('mime_content_type')) {
        $detected = mime_content_type($tmpName);
        if (is_string($detected) && $detected !== '') {
            return $detected;
        }
    }

    if ($tmpName !== '' && class_exists('finfo')) {
        $finfo = new finfo(FILEINFO_MIME_TYPE);
        $detected = $finfo->file($tmpName);
        if (is_string($detected) && $detected !== '') {
            return $detected;
        }
    }

    $extension = strtolower(pathinfo((string)($file['name'] ?? ''), PATHINFO_EXTENSION));
    return match ($extension) {
        'jpg', 'jpeg' => 'image/jpeg',
        'png' => 'image/png',
        'webp' => 'image/webp',
        default => 'application/octet-stream',
    };
}

function upload_activity_image(array $file): ?array
{
    if (!isset($file['tmp_name']) || (int)($file['error'] ?? UPLOAD_ERR_NO_FILE) === UPLOAD_ERR_NO_FILE) {
        return null;
    }

    if ((int)$file['error'] !== UPLOAD_ERR_OK) {
        respond_error('Image upload failed.', 400);
    }

    $mime = detect_uploaded_mime_type($file);
    $extension = match ($mime) {
        'image/jpeg' => 'jpg',
        'image/png' => 'png',
        'image/webp' => 'webp',
        default => null,
    };

    if ($extension === null) {
        respond_error('Only JPG, PNG, and WEBP images are supported.', 422);
    }

    $subFolder = date('Y/m');
    $targetDir = rtrim(UPLOAD_ACTIVITY_DIR, '/') . '/' . $subFolder;
    ensure_directory($targetDir);

    $fileName = uniqid('activity_', true) . '.' . $extension;
    $targetPath = $targetDir . '/' . $fileName;

    if (!move_uploaded_file($file['tmp_name'], $targetPath)) {
        respond_error('Failed to save uploaded image.', 500);
    }

    return [
        'image_path' => '/uploads/activities/' . $subFolder . '/' . $fileName,
        'image_url' => rtrim(UPLOAD_BASE_URL, '/') . '/' . $subFolder . '/' . $fileName,
        'image_mime' => $mime,
        'image_original_name' => $file['name'] ?? null,
        'disk_path' => $targetPath,
    ];
}

function current_timestamp(): string
{
    return gmdate('Y-m-d H:i:s');
}
