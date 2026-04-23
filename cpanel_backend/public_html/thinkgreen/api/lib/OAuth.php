<?php
declare(strict_types=1);

function oauth_provider_enabled(string $provider): bool
{
    $provider = strtolower($provider);

    if ($provider === 'google') {
        return GOOGLE_OAUTH_ENABLED
            && GOOGLE_CLIENT_ID !== ''
            && GOOGLE_CLIENT_SECRET !== ''
            && strpos(GOOGLE_CLIENT_ID, 'YOUR_GOOGLE_CLIENT_ID') === false
            && strpos(GOOGLE_CLIENT_SECRET, 'YOUR_GOOGLE_CLIENT_SECRET') === false;
    }

    if ($provider === 'strava') {
        return STRAVA_OAUTH_ENABLED
            && STRAVA_CLIENT_ID !== ''
            && STRAVA_CLIENT_SECRET !== ''
            && strpos(STRAVA_CLIENT_ID, 'YOUR_STRAVA_CLIENT_ID') === false
            && strpos(STRAVA_CLIENT_SECRET, 'YOUR_STRAVA_CLIENT_SECRET') === false;
    }

    return false;
}

function oauth_app_callback_uri(): string
{
    return APP_OAUTH_CALLBACK_SCHEME . '://' . APP_OAUTH_CALLBACK_HOST;
}

function oauth_callback_url(string $provider): string
{
    return rtrim(API_BASE_URL, '/') . '/oauth/' . strtolower($provider) . '_callback.php';
}

function oauth_create_request(PDO $pdo, ?int $userId, string $provider, string $purpose): array
{
    $state = bin2hex(random_bytes(24));
    $stmt = $pdo->prepare(
        'INSERT INTO oauth_requests
         (user_id, provider, purpose, state, expires_at, created_at, updated_at)
         VALUES (:user_id, :provider, :purpose, :state, DATE_ADD(UTC_TIMESTAMP(), INTERVAL 15 MINUTE), UTC_TIMESTAMP(), UTC_TIMESTAMP())'
    );
    $stmt->bindValue(':user_id', $userId, $userId === null ? PDO::PARAM_NULL : PDO::PARAM_INT);
    $stmt->bindValue(':provider', strtolower($provider), PDO::PARAM_STR);
    $stmt->bindValue(':purpose', strtolower($purpose), PDO::PARAM_STR);
    $stmt->bindValue(':state', $state, PDO::PARAM_STR);
    $stmt->execute();

    return [
        'id' => (int)$pdo->lastInsertId(),
        'state' => $state,
    ];
}

function oauth_find_request_by_state(PDO $pdo, string $provider, string $state): ?array
{
    $stmt = $pdo->prepare(
        'SELECT *
         FROM oauth_requests
         WHERE provider = :provider
           AND state = :state
           AND consumed_at IS NULL
           AND expires_at > UTC_TIMESTAMP()
         LIMIT 1'
    );
    $stmt->execute([
        ':provider' => strtolower($provider),
        ':state' => $state,
    ]);

    $request = $stmt->fetch();
    return is_array($request) ? $request : null;
}

function oauth_complete_request(PDO $pdo, int $requestId, array $payload): string
{
    $handoffCode = bin2hex(random_bytes(24));
    $encodedPayload = json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    if ($encodedPayload === false) {
        throw new RuntimeException('Failed to encode OAuth result payload.');
    }

    $stmt = $pdo->prepare(
        'UPDATE oauth_requests
         SET handoff_code = :handoff_code,
             result_payload_json = :result_payload_json,
             completed_at = UTC_TIMESTAMP(),
             updated_at = UTC_TIMESTAMP()
         WHERE id = :id'
    );
    $stmt->execute([
        ':handoff_code' => $handoffCode,
        ':result_payload_json' => $encodedPayload,
        ':id' => $requestId,
    ]);

    return $handoffCode;
}

function oauth_consume_result(PDO $pdo, string $handoffCode): array
{
    $stmt = $pdo->prepare(
        'SELECT id, result_payload_json
         FROM oauth_requests
         WHERE handoff_code = :handoff_code
           AND completed_at IS NOT NULL
           AND consumed_at IS NULL
           AND expires_at > UTC_TIMESTAMP()
         LIMIT 1'
    );
    $stmt->execute([':handoff_code' => $handoffCode]);
    $request = $stmt->fetch();

    if (!$request) {
        respond_error('Invalid or expired OAuth handoff code.', 410);
    }

    $payload = json_decode((string)($request['result_payload_json'] ?? '{}'), true);
    if (!is_array($payload)) {
        $payload = [];
    }

    $update = $pdo->prepare(
        'UPDATE oauth_requests
         SET consumed_at = UTC_TIMESTAMP(),
             updated_at = UTC_TIMESTAMP()
         WHERE id = :id'
    );
    $update->execute([':id' => $request['id']]);

    return $payload;
}

function oauth_redirect_success(string $provider, string $purpose, string $handoffCode): void
{
    oauth_redirect_to_app([
        'provider' => strtolower($provider),
        'purpose' => strtolower($purpose),
        'code' => $handoffCode,
    ]);
}

function oauth_redirect_error(string $provider, string $purpose, string $message, string $errorCode = 'oauth_error'): void
{
    oauth_redirect_to_app([
        'provider' => strtolower($provider),
        'purpose' => strtolower($purpose),
        'error' => $errorCode,
        'message' => $message,
    ]);
}

function oauth_redirect_to_app(array $query): void
{
    $uri = oauth_app_callback_uri() . '?' . http_build_query($query);
    header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');
    header('Pragma: no-cache');
    header('Location: ' . $uri, true, 302);
    exit;
}

function oauth_http_post_form_json(string $url, array $fields, array $headers = []): array
{
    return oauth_http_json_request(
        $url,
        'POST',
        array_merge(['Content-Type: application/x-www-form-urlencoded'], $headers),
        http_build_query($fields)
    );
}

function oauth_http_get_json(string $url, array $headers = []): array
{
    return oauth_http_json_request($url, 'GET', $headers);
}

function oauth_http_json_request(string $url, string $method, array $headers = [], ?string $body = null): array
{
    if (!function_exists('curl_init')) {
        throw new RuntimeException('cURL is required for OAuth integrations.');
    }

    $ch = curl_init($url);
    if ($ch === false) {
        throw new RuntimeException('Failed to initialize OAuth request.');
    }

    $formattedHeaders = [];
    foreach ($headers as $key => $value) {
        if (is_int($key)) {
            $formattedHeaders[] = (string)$value;
            continue;
        }

        $formattedHeaders[] = $key . ': ' . $value;
    }

    curl_setopt_array($ch, [
        CURLOPT_CUSTOMREQUEST => strtoupper($method),
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_HTTPHEADER => $formattedHeaders,
        CURLOPT_POSTFIELDS => $body,
        CURLOPT_TIMEOUT => 25,
    ]);

    $rawBody = curl_exec($ch);
    $httpCode = (int)curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $curlError = curl_error($ch);
    curl_close($ch);

    if (!is_string($rawBody)) {
        throw new RuntimeException('OAuth request failed: ' . ($curlError !== '' ? $curlError : 'unknown error'));
    }

    $decoded = json_decode($rawBody, true);
    if (!is_array($decoded)) {
        throw new RuntimeException('OAuth provider returned an invalid JSON response.');
    }

    if ($httpCode >= 400) {
        $message = (string)($decoded['message'] ?? $decoded['error_description'] ?? $decoded['error'] ?? 'OAuth request failed.');
        throw new RuntimeException($message);
    }

    return $decoded;
}

function oauth_google_authorize_url(string $state): string
{
    return 'https://accounts.google.com/o/oauth2/v2/auth?' . http_build_query([
        'client_id' => GOOGLE_CLIENT_ID,
        'redirect_uri' => oauth_callback_url('google'),
        'response_type' => 'code',
        'scope' => 'openid email profile',
        'state' => $state,
        'include_granted_scopes' => 'true',
        'prompt' => 'select_account',
    ]);
}

function oauth_google_complete(PDO $pdo, string $state, string $code): string
{
    $request = oauth_find_request_by_state($pdo, 'google', $state);
    if (!$request) {
        throw new RuntimeException('Google OAuth session is invalid or expired.');
    }

    $tokenPayload = oauth_http_post_form_json('https://oauth2.googleapis.com/token', [
        'code' => $code,
        'client_id' => GOOGLE_CLIENT_ID,
        'client_secret' => GOOGLE_CLIENT_SECRET,
        'redirect_uri' => oauth_callback_url('google'),
        'grant_type' => 'authorization_code',
    ]);

    $accessToken = (string)($tokenPayload['access_token'] ?? '');
    if ($accessToken === '') {
        throw new RuntimeException('Google did not return an access token.');
    }

    $profile = oauth_http_get_json('https://openidconnect.googleapis.com/v1/userinfo', [
        'Authorization' => 'Bearer ' . $accessToken,
    ]);

    $email = normalize_email((string)($profile['email'] ?? ''));
    if ($email === '' || filter_var($email, FILTER_VALIDATE_EMAIL) === false) {
        throw new RuntimeException('Google account email is missing or invalid.');
    }
    if (isset($profile['email_verified']) && $profile['email_verified'] !== true) {
        throw new RuntimeException('Google account email is not verified.');
    }

    $user = oauth_find_user_by_email($pdo, $email);
    if (!$user) {
        $insert = $pdo->prepare(
            'INSERT INTO users
             (public_id, full_name, email, phone, date_of_birth, password_hash, avatar_url, role, locale, created_at, updated_at)
             VALUES
             (:public_id, :full_name, :email, NULL, NULL, :password_hash, :avatar_url, "user", :locale, UTC_TIMESTAMP(), UTC_TIMESTAMP())'
        );
        $insert->execute([
            ':public_id' => generate_public_id('TG'),
            ':full_name' => trim((string)($profile['name'] ?? 'Google User')) ?: 'Google User',
            ':email' => $email,
            ':password_hash' => password_hash(bin2hex(random_bytes(24)), PASSWORD_DEFAULT),
            ':avatar_url' => trim((string)($profile['picture'] ?? '')) ?: null,
            ':locale' => oauth_normalize_locale((string)($profile['locale'] ?? 'en')),
        ]);

        $user = oauth_find_user_by_email($pdo, $email);
        if (!$user) {
            throw new RuntimeException('Failed to create the Google user account.');
        }
    } else {
        $update = $pdo->prepare(
            'UPDATE users
             SET full_name = CASE WHEN full_name = "" OR full_name IS NULL THEN :full_name ELSE full_name END,
                 avatar_url = CASE WHEN (:avatar_url_value IS NOT NULL AND :avatar_url_present != "") THEN :avatar_url_update ELSE avatar_url END,
                 locale = CASE WHEN locale NOT IN ("he", "en") OR locale IS NULL OR locale = "" THEN :locale_value ELSE locale END,
                 updated_at = UTC_TIMESTAMP()
             WHERE id = :id'
        );
        $avatarUrl = trim((string)($profile['picture'] ?? ''));
        $update->execute([
            ':full_name' => trim((string)($profile['name'] ?? 'Google User')) ?: 'Google User',
            ':avatar_url_value' => $avatarUrl !== '' ? $avatarUrl : null,
            ':avatar_url_present' => $avatarUrl,
            ':avatar_url_update' => $avatarUrl !== '' ? $avatarUrl : null,
            ':locale_value' => oauth_normalize_locale((string)($profile['locale'] ?? 'en')),
            ':id' => $user['id'],
        ]);

        $user = oauth_find_user_by_email($pdo, $email);
        if (!$user) {
            throw new RuntimeException('Failed to refresh the Google user account.');
        }
    }

    $token = issue_auth_token($pdo, (int)$user['id']);
    $handoffCode = oauth_complete_request($pdo, (int)$request['id'], [
        'token' => $token,
        'user' => oauth_public_user_payload($user),
    ]);

    return $handoffCode;
}

function oauth_strava_authorize_url(string $state): string
{
    return 'https://www.strava.com/oauth/authorize?' . http_build_query([
        'client_id' => STRAVA_CLIENT_ID,
        'redirect_uri' => oauth_callback_url('strava'),
        'response_type' => 'code',
        'approval_prompt' => 'auto',
        'scope' => 'read,activity:read_all,profile:read_all',
        'state' => $state,
    ]);
}

function oauth_strava_complete(PDO $pdo, string $state, string $code): string
{
    $request = oauth_find_request_by_state($pdo, 'strava', $state);
    if (!$request || (int)($request['user_id'] ?? 0) <= 0) {
        throw new RuntimeException('Strava OAuth session is invalid or expired.');
    }

    $tokenPayload = oauth_http_post_form_json('https://www.strava.com/oauth/token', [
        'client_id' => STRAVA_CLIENT_ID,
        'client_secret' => STRAVA_CLIENT_SECRET,
        'code' => $code,
        'grant_type' => 'authorization_code',
    ]);

    oauth_store_strava_connection($pdo, (int)$request['user_id'], $tokenPayload);
    $summary = oauth_sync_strava_activities($pdo, (int)$request['user_id']);
    $connection = oauth_get_app_connection($pdo, (int)$request['user_id'], 'strava');

    $handoffCode = oauth_complete_request($pdo, (int)$request['id'], [
        'provider' => 'strava',
        'connection' => oauth_connection_payload($connection),
        'sync_summary' => $summary,
    ]);

    return $handoffCode;
}

function oauth_sync_strava_activities(PDO $pdo, int $userId): array
{
    $connection = oauth_get_app_connection($pdo, $userId, 'strava');
    if (!$connection || ($connection['connection_status'] ?? '') !== 'connected') {
        throw new RuntimeException('Strava is not connected for this user.');
    }

    $connection = oauth_refresh_strava_token_if_needed($pdo, $connection);
    $accessToken = (string)($connection['access_token'] ?? '');
    if ($accessToken === '') {
        throw new RuntimeException('Strava access token is missing.');
    }

    $activitiesUrl = 'https://www.strava.com/api/v3/athlete/activities?' . http_build_query([
        'per_page' => STRAVA_SYNC_PAGE_SIZE,
    ]);
    $stravaActivities = oauth_http_get_json($activitiesUrl, [
        'Authorization' => 'Bearer ' . $accessToken,
    ]);

    if (!isset($stravaActivities[0]) || !is_array($stravaActivities[0])) {
        $stravaActivities = [];
    }

    $definition = oauth_strava_activity_definition($pdo);
    $definitionId = $definition !== null ? (int)$definition['id'] : null;
    $defaultPoints = $definition !== null ? (int)$definition['default_points'] : 30;

    $checkExisting = $pdo->prepare(
        'SELECT id
         FROM activities
         WHERE user_id = :user_id
           AND external_provider = "strava"
           AND external_activity_id = :external_activity_id
         LIMIT 1'
    );
    $insertActivity = $pdo->prepare(
        'INSERT INTO activities
         (public_id, user_id, activity_definition_id, title_snapshot, source, activity_datetime, status, points_awarded,
          client_verified, created_at, updated_at, external_provider, external_activity_id)
         VALUES
         (:public_id, :user_id, :activity_definition_id, :title_snapshot, "strava", :activity_datetime, "approved", :points_awarded,
          1, UTC_TIMESTAMP(), UTC_TIMESTAMP(), "strava", :external_activity_id)'
    );

    $insertedCount = 0;
    $awardedPoints = 0;

    foreach ($stravaActivities as $activity) {
        if (!is_array($activity)) {
            continue;
        }

        $mapped = oauth_map_strava_activity($activity, $defaultPoints);
        if ($mapped === null) {
            continue;
        }

        $checkExisting->execute([
            ':user_id' => $userId,
            ':external_activity_id' => $mapped['external_activity_id'],
        ]);
        if ($checkExisting->fetch()) {
            continue;
        }

        $insertActivity->bindValue(':public_id', generate_public_id('ACT'), PDO::PARAM_STR);
        $insertActivity->bindValue(':user_id', $userId, PDO::PARAM_INT);
        $insertActivity->bindValue(':activity_definition_id', $definitionId, $definitionId === null ? PDO::PARAM_NULL : PDO::PARAM_INT);
        $insertActivity->bindValue(':title_snapshot', $mapped['title_snapshot'], PDO::PARAM_STR);
        $insertActivity->bindValue(':activity_datetime', $mapped['activity_datetime'], PDO::PARAM_STR);
        $insertActivity->bindValue(':points_awarded', $mapped['points_awarded'], PDO::PARAM_INT);
        $insertActivity->bindValue(':external_activity_id', $mapped['external_activity_id'], PDO::PARAM_STR);
        $insertActivity->execute();

        $activityId = (int)$pdo->lastInsertId();
        upsert_points_event(
            $pdo,
            $userId,
            (int)$mapped['points_awarded'],
            'activity_approved',
            'activity',
            $activityId,
            'Imported from Strava'
        );

        $insertedCount++;
        $awardedPoints += (int)$mapped['points_awarded'];
    }

    $updateConnection = $pdo->prepare(
        'UPDATE app_connections
         SET last_synced_at = UTC_TIMESTAMP(),
             updated_at = UTC_TIMESTAMP()
         WHERE user_id = :user_id AND provider = "strava"'
    );
    $updateConnection->execute([':user_id' => $userId]);

    sync_user_challenges($pdo, $userId);
    $newBalance = refresh_user_points($pdo, $userId);

    return [
        'provider' => 'strava',
        'inserted_count' => $insertedCount,
        'awarded_points' => $awardedPoints,
        'points_balance' => $newBalance,
        'synced_at' => current_timestamp(),
    ];
}

function oauth_store_strava_connection(PDO $pdo, int $userId, array $tokenPayload): void
{
    $accessToken = trim((string)($tokenPayload['access_token'] ?? ''));
    $refreshToken = trim((string)($tokenPayload['refresh_token'] ?? ''));
    $athlete = isset($tokenPayload['athlete']) && is_array($tokenPayload['athlete']) ? $tokenPayload['athlete'] : [];
    $athleteId = trim((string)($athlete['id'] ?? ''));
    $scope = trim((string)($tokenPayload['scope'] ?? 'read,activity:read_all,profile:read_all'));
    $expiresAtTimestamp = (int)($tokenPayload['expires_at'] ?? 0);
    $expiresAt = $expiresAtTimestamp > 0
        ? gmdate('Y-m-d H:i:s', $expiresAtTimestamp)
        : gmdate('Y-m-d H:i:s', time() + 21600);
    $providerPayload = json_encode($tokenPayload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    if ($providerPayload === false) {
        $providerPayload = '{}';
    }

    if ($accessToken === '' || $refreshToken === '') {
        throw new RuntimeException('Strava did not return the required tokens.');
    }

    $stmt = $pdo->prepare(
        'INSERT INTO app_connections
         (user_id, provider, external_user_id, connection_status, connected_at, last_synced_at,
          access_token, refresh_token, token_expires_at, scopes, provider_payload_json, created_at, updated_at)
         VALUES
         (:user_id, "strava", :external_user_id, "connected", UTC_TIMESTAMP(), NULL,
          :access_token, :refresh_token, :token_expires_at, :scopes, :provider_payload_json, UTC_TIMESTAMP(), UTC_TIMESTAMP())
         ON DUPLICATE KEY UPDATE
           external_user_id = VALUES(external_user_id),
           connection_status = "connected",
           connected_at = UTC_TIMESTAMP(),
           access_token = VALUES(access_token),
           refresh_token = VALUES(refresh_token),
           token_expires_at = VALUES(token_expires_at),
           scopes = VALUES(scopes),
           provider_payload_json = VALUES(provider_payload_json),
           updated_at = UTC_TIMESTAMP()'
    );
    $stmt->execute([
        ':user_id' => $userId,
        ':external_user_id' => $athleteId !== '' ? $athleteId : null,
        ':access_token' => $accessToken,
        ':refresh_token' => $refreshToken,
        ':token_expires_at' => $expiresAt,
        ':scopes' => $scope !== '' ? $scope : null,
        ':provider_payload_json' => $providerPayload,
    ]);
}

function oauth_refresh_strava_token_if_needed(PDO $pdo, array $connection): array
{
    $expiresAt = strtotime((string)($connection['token_expires_at'] ?? ''));
    if ($expiresAt !== false && $expiresAt > time() + 300) {
        return $connection;
    }

    $refreshToken = trim((string)($connection['refresh_token'] ?? ''));
    if ($refreshToken === '') {
        throw new RuntimeException('Strava refresh token is missing.');
    }

    $tokenPayload = oauth_http_post_form_json('https://www.strava.com/oauth/token', [
        'client_id' => STRAVA_CLIENT_ID,
        'client_secret' => STRAVA_CLIENT_SECRET,
        'grant_type' => 'refresh_token',
        'refresh_token' => $refreshToken,
    ]);

    oauth_store_strava_connection($pdo, (int)$connection['user_id'], $tokenPayload);
    $refreshed = oauth_get_app_connection($pdo, (int)$connection['user_id'], 'strava');
    if (!$refreshed) {
        throw new RuntimeException('Failed to refresh the Strava connection.');
    }

    return $refreshed;
}

function oauth_get_app_connection(PDO $pdo, int $userId, string $provider): ?array
{
    $stmt = $pdo->prepare(
        'SELECT *
         FROM app_connections
         WHERE user_id = :user_id
           AND provider = :provider
         LIMIT 1'
    );
    $stmt->execute([
        ':user_id' => $userId,
        ':provider' => strtolower($provider),
    ]);

    $connection = $stmt->fetch();
    return is_array($connection) ? $connection : null;
}

function oauth_connection_payload(?array $connection): array
{
    if (!$connection) {
        return [
            'provider' => null,
            'external_user_id' => null,
            'connection_status' => 'disconnected',
            'connected_at' => null,
            'last_synced_at' => null,
        ];
    }

    return [
        'provider' => $connection['provider'],
        'external_user_id' => $connection['external_user_id'],
        'connection_status' => $connection['connection_status'],
        'connected_at' => $connection['connected_at'],
        'last_synced_at' => $connection['last_synced_at'],
    ];
}

function oauth_disconnect_connection(PDO $pdo, int $userId, string $provider): array
{
    $stmt = $pdo->prepare(
        'UPDATE app_connections
         SET connection_status = "disconnected",
             access_token = NULL,
             refresh_token = NULL,
             token_expires_at = NULL,
             scopes = NULL,
             provider_payload_json = NULL,
             updated_at = UTC_TIMESTAMP()
         WHERE user_id = :user_id
           AND provider = :provider'
    );
    $stmt->execute([
        ':user_id' => $userId,
        ':provider' => strtolower($provider),
    ]);

    return oauth_connection_payload(oauth_get_app_connection($pdo, $userId, $provider));
}

function oauth_map_strava_activity(array $activity, int $defaultPoints): ?array
{
    $type = strtolower(trim((string)($activity['type'] ?? '')));

    if ($type === 'ride' || $type === 'virtualride' || $type === 'ebikeride') {
        $title = 'Strava Ride';
    } elseif ($type === 'run' || $type === 'trailrun') {
        $title = 'Strava Run';
    } elseif ($type === 'walk' || $type === 'hike') {
        $title = 'Strava Walk';
    } else {
        $title = null;
    }

    if ($title === null) {
        return null;
    }

    $externalId = trim((string)($activity['id'] ?? ''));
    if ($externalId === '') {
        return null;
    }

    $activityDate = trim((string)($activity['start_date_local'] ?? '')) ?: trim((string)($activity['start_date'] ?? ''));
    $dateTime = DateTime::createFromFormat(DateTimeInterface::ATOM, $activityDate) ?: new DateTime($activityDate ?: 'now');

    return [
        'external_activity_id' => $externalId,
        'title_snapshot' => $title,
        'activity_datetime' => gmdate('Y-m-d H:i:s', $dateTime->getTimestamp()),
        'points_awarded' => $defaultPoints,
    ];
}

function oauth_strava_activity_definition(PDO $pdo): ?array
{
    $stmt = $pdo->prepare(
        'SELECT id, default_points
         FROM activity_definitions
         WHERE slug = "walked_biked_to_work"
         LIMIT 1'
    );
    $stmt->execute();
    $definition = $stmt->fetch();

    return is_array($definition) ? $definition : null;
}

function oauth_find_user_by_email(PDO $pdo, string $email): ?array
{
    $stmt = $pdo->prepare('SELECT * FROM users WHERE email = :email LIMIT 1');
    $stmt->execute([':email' => normalize_email($email)]);
    $user = $stmt->fetch();

    return is_array($user) ? $user : null;
}

function oauth_public_user_payload(array $user): array
{
    return [
        'id' => (int)$user['id'],
        'public_id' => $user['public_id'],
        'full_name' => $user['full_name'],
        'email' => $user['email'],
        'phone' => $user['phone'],
        'date_of_birth' => $user['date_of_birth'],
        'avatar_url' => $user['avatar_url'],
        'role' => $user['role'],
        'locale' => $user['locale'],
        'notifications_enabled' => (bool)$user['notifications_enabled'],
        'dark_mode' => (bool)$user['dark_mode'],
        'location_services_enabled' => (bool)$user['location_services_enabled'],
        'points_balance' => (int)$user['points_balance'],
    ];
}

function oauth_normalize_locale(string $locale): string
{
    return strpos(strtolower(trim($locale)), 'he') === 0 ? 'he' : 'en';
}
