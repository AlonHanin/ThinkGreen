<?php
declare(strict_types=1);

function clarifai_is_configured(): bool
{
    return CLARIFAI_ENABLED
        && CLARIFAI_API_KEY !== ''
        && strpos(CLARIFAI_API_KEY, 'YOUR_CLARIFAI_API_KEY') === false;
}

function clarifai_string_contains($haystack, $needle): bool
{
    return $needle !== '' && strpos((string)$haystack, (string)$needle) !== false;
}

function activity_verification_keywords(string $slug): array
{
    $map = [
        'recycled_plastic_bottles' => ['recycling', 'recycle', 'bottle', 'plastic'],
        'used_public_transport' => ['transport', 'bus', 'train', 'tram', 'station'],
        'used_reusable_bottle' => ['bottle', 'reusable', 'cup', 'flask'],
        'walked_biked_to_work' => ['bicycle', 'bike', 'road', 'walking', 'person'],
    ];

    return isset($map[$slug]) ? $map[$slug] : [];
}

function analyze_activity_image(string $activitySlug, string $imagePath): array
{
    $keywords = activity_verification_keywords($activitySlug);
    if ($keywords === []) {
        return [
            'matched' => false,
            'tags' => [],
            'keywords' => [],
            'reason' => 'unsupported_activity',
        ];
    }

    $tags = clarifai_analyze_image_file($imagePath);
    if ($tags === []) {
        return [
            'matched' => false,
            'tags' => [],
            'keywords' => $keywords,
            'reason' => clarifai_is_configured() ? 'no_tags_detected' : 'clarifai_not_configured',
        ];
    }

    foreach ($tags as $tag) {
        foreach ($keywords as $keyword) {
            if (clarifai_string_contains($tag, $keyword) || clarifai_string_contains($keyword, $tag)) {
                return [
                    'matched' => true,
                    'tags' => $tags,
                    'keywords' => $keywords,
                    'reason' => 'keyword_match',
                ];
            }
        }
    }

    return [
        'matched' => false,
        'tags' => $tags,
        'keywords' => $keywords,
        'reason' => 'keyword_mismatch',
    ];
}

function clarifai_analyze_image_file(string $imagePath): array
{
    if (!clarifai_is_configured() || !is_file($imagePath)) {
        return [];
    }

    if (!function_exists('curl_init')) {
        return [];
    }

    $imageBytes = file_get_contents($imagePath);
    if ($imageBytes === false || $imageBytes === '') {
        return [];
    }

    $payload = json_encode([
        'user_app_id' => [
            'user_id' => CLARIFAI_USER_ID,
            'app_id' => CLARIFAI_APP_ID,
        ],
        'inputs' => [[
            'data' => [
                'image' => [
                    'base64' => base64_encode($imageBytes),
                ],
            ],
        ]],
    ], JSON_UNESCAPED_SLASHES);

    if ($payload === false) {
        return [];
    }

    $url = sprintf(
        'https://api.clarifai.com/v2/users/%s/apps/%s/models/%s/outputs',
        rawurlencode(CLARIFAI_USER_ID),
        rawurlencode(CLARIFAI_APP_ID),
        rawurlencode(CLARIFAI_MODEL_ID)
    );
    $ch = curl_init($url);
    curl_setopt_array($ch, [
        CURLOPT_POST => true,
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_HTTPHEADER => [
            'Authorization: Key ' . CLARIFAI_API_KEY,
            'Content-Type: application/json',
        ],
        CURLOPT_POSTFIELDS => $payload,
        CURLOPT_TIMEOUT => 20,
    ]);

    $rawResponse = curl_exec($ch);
    $httpCode = (int)curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);

    if (!is_string($rawResponse) || $httpCode >= 400) {
        error_log('Clarifai request failed. HTTP ' . $httpCode . ' response: ' . (is_string($rawResponse) ? $rawResponse : ''));
        return [];
    }

    $decoded = json_decode($rawResponse, true);
    if (!is_array($decoded)) {
        return [];
    }

    $concepts = isset($decoded['outputs'][0]['data']['concepts']) ? $decoded['outputs'][0]['data']['concepts'] : null;
    if (!is_array($concepts)) {
        return [];
    }

    $tags = [];
    foreach ($concepts as $concept) {
        $name = strtolower(trim((string)(isset($concept['name']) ? $concept['name'] : '')));
        $score = (float)(isset($concept['value']) ? $concept['value'] : 0);
        if ($name === '' || $score < CLARIFAI_MIN_SCORE) {
            continue;
        }
        $tags[] = $name;
    }

    return array_values(array_unique($tags));
}
