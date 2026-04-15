<?php
declare(strict_types=1);

function hash_token(string $token): string
{
    return hash('sha256', $token);
}

function bearer_token(): ?string
{
    $header = $_SERVER['HTTP_AUTHORIZATION'] ?? $_SERVER['REDIRECT_HTTP_AUTHORIZATION'] ?? '';
    if (!$header && function_exists('apache_request_headers')) {
        $headers = apache_request_headers();
        $header = $headers['Authorization'] ?? $headers['authorization'] ?? '';
    }

    if (!preg_match('/Bearer\s+(.+)/i', $header, $matches)) {
        return null;
    }

    return trim($matches[1]);
}

function issue_auth_token(PDO $pdo, int $userId): string
{
    $token = bin2hex(random_bytes(32));
    $stmt = $pdo->prepare(
        'INSERT INTO auth_tokens (user_id, token_hash, expires_at, created_at)
         VALUES (:user_id, :token_hash, DATE_ADD(UTC_TIMESTAMP(), INTERVAL :days DAY), UTC_TIMESTAMP())'
    );
    $stmt->bindValue(':user_id', $userId, PDO::PARAM_INT);
    $stmt->bindValue(':token_hash', hash_token($token), PDO::PARAM_STR);
    $stmt->bindValue(':days', TOKEN_TTL_DAYS, PDO::PARAM_INT);
    $stmt->execute();

    return $token;
}

function revoke_current_token(PDO $pdo): void
{
    $token = bearer_token();
    if ($token === null) {
        return;
    }

    $stmt = $pdo->prepare('DELETE FROM auth_tokens WHERE token_hash = :token_hash');
    $stmt->execute([':token_hash' => hash_token($token)]);
}

function require_auth_user(PDO $pdo): array
{
    $token = bearer_token();
    if ($token === null) {
        respond_error('Missing bearer token.', 401);
    }

    $stmt = $pdo->prepare(
        'SELECT u.*
         FROM auth_tokens t
         INNER JOIN users u ON u.id = t.user_id
         WHERE t.token_hash = :token_hash
           AND t.expires_at > UTC_TIMESTAMP()
         LIMIT 1'
    );
    $stmt->execute([':token_hash' => hash_token($token)]);
    $user = $stmt->fetch();

    if (!$user) {
        respond_error('Invalid or expired token.', 401);
    }

    $touch = $pdo->prepare('UPDATE auth_tokens SET last_used_at = UTC_TIMESTAMP() WHERE token_hash = :token_hash');
    $touch->execute([':token_hash' => hash_token($token)]);

    return $user;
}

function require_admin_user(PDO $pdo): array
{
    $user = require_auth_user($pdo);
    if (($user['role'] ?? 'user') !== 'admin') {
        respond_error('Admin access required.', 403);
    }

    return $user;
}
