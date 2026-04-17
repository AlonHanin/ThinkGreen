<?php
declare(strict_types=1);

date_default_timezone_set('UTC');

const DB_HOST = 'localhost';
const DB_NAME = 'YOUR_CPANEL_DATABASE_NAME';
const DB_USER = 'YOUR_CPANEL_DATABASE_USER';
const DB_PASS = 'YOUR_CPANEL_DATABASE_PASSWORD';

const APP_DEBUG = true;
const TOKEN_TTL_DAYS = 30;
const RESET_PIN_TTL_MINUTES = 10;

/**
 * Example:
 * const APP_BASE_URL = 'https://your-domain.example/thinkgreen';
 * If your API is under a subdomain, set it accordingly.
 */
const APP_BASE_URL = 'https://YOUR-DOMAIN/thinkgreen';
const API_BASE_URL = APP_BASE_URL . '/api';
const UPLOAD_BASE_URL = APP_BASE_URL . '/uploads/activities';

const CLARIFAI_ENABLED = false;
const CLARIFAI_API_KEY = 'YOUR_CLARIFAI_API_KEY';
const CLARIFAI_USER_ID = 'clarifai';
const CLARIFAI_APP_ID = 'main';
const CLARIFAI_MODEL_ID = 'general-image-recognition';
const CLARIFAI_MIN_SCORE = 0.85;

/**
 * Absolute filesystem path to the activities upload directory.
 * Expected public path:
 *   public_html/thinkgreen/uploads/activities
 */
const UPLOAD_ACTIVITY_DIR = __DIR__ . '/../../uploads/activities';
