<?php
declare(strict_types=1);

date_default_timezone_set('UTC');

const DB_HOST = 'localhost';
const DB_NAME = 'islidorav_thinkgreen';
const DB_USER = 'islidorav_thinkuser';
const DB_PASS = 'thinkgreen1!';

const APP_DEBUG = true;
const TOKEN_TTL_DAYS = 30;
const RESET_PIN_TTL_MINUTES = 10;

/**
 * Example:
 * const APP_BASE_URL = 'https://your-domain.example/thinkgreen';
 * If your API is under a subdomain, set it accordingly.
 */
const APP_BASE_URL = 'https://islidorav.mtacloud.co.il/thinkgreen';
const API_BASE_URL = APP_BASE_URL . '/api';
const UPLOAD_BASE_URL = APP_BASE_URL . '/uploads/activities';
const PROFILE_UPLOAD_BASE_URL = APP_BASE_URL . '/uploads/profiles';

const CLARIFAI_ENABLED = true;
const CLARIFAI_API_KEY = 'e2d286cf5fd44e6c86c5115a37b9e9ab';
const CLARIFAI_USER_ID = 'clarifai';
const CLARIFAI_APP_ID = 'main';
const CLARIFAI_MODEL_ID = 'general-image-recognition';
const CLARIFAI_MIN_SCORE = 0.8;

const APP_OAUTH_CALLBACK_SCHEME = 'thinkgreen';
const APP_OAUTH_CALLBACK_HOST = 'oauth-callback';

const GOOGLE_OAUTH_ENABLED = true;
const GOOGLE_CLIENT_ID = '1033622548984-u8sekfcm7ranfbu6s9ttoceei6fsa5t3.apps.googleusercontent.com';
const GOOGLE_CLIENT_SECRET = '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';

const STRAVA_OAUTH_ENABLED = true;
const STRAVA_CLIENT_ID = '229607';
const STRAVA_CLIENT_SECRET = 'efaeb12e152c67010274090f00d55159b0399d2d';
const STRAVA_SYNC_PAGE_SIZE = 30;

/**
 * Absolute filesystem path to the activities upload directory.
 * Expected public path:
 *   public_html/thinkgreen/uploads/activities
 */
const UPLOAD_ACTIVITY_DIR = __DIR__ . '/../../uploads/activities';
const UPLOAD_PROFILE_DIR = __DIR__ . '/../../uploads/profiles';
