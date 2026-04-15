# Think Green – cPanel upload guide

This package is designed for the stack:

**Flutter app → PHP API on cPanel → MySQL/MariaDB**

## Recommended public URL structure

If your college hosting gives you a normal site root, upload the backend like this:

```text
public_html/
└── thinkgreen/
    ├── api/
    │   ├── index.php
    │   ├── bootstrap.php
    │   ├── config/
    │   ├── lib/
    │   ├── auth/
    │   ├── user/
    │   ├── activities/
    │   ├── admin/
    │   ├── challenges/
    │   ├── rewards/
    │   └── meta/
    └── uploads/
        └── activities/
            └── .htaccess
```

With this structure, your base URL will usually be:

```text
https://YOUR-DOMAIN/thinkgreen
```

and your API root will be:

```text
https://YOUR-DOMAIN/thinkgreen/api
```

## What to upload where

### 1. Database SQL
**Do not upload the SQL file into `public_html` unless you must.**  
Instead:

- Open **cPanel → phpMyAdmin**
- Create a new database
- Import:

```text
database/thinkgreen_mysql_cpanel_v1.sql
```

### 2. PHP API files
Upload everything from:

```text
public_html/thinkgreen/api/
```

into the matching folder on cPanel.

### 3. Uploads folder
Upload this folder too:

```text
public_html/thinkgreen/uploads/activities/.htaccess
```

Make sure the directory exists:

```text
public_html/thinkgreen/uploads/activities
```

The API will save uploaded activity images there.

## Important config file

After upload, open:

```text
public_html/thinkgreen/api/config/config.php
```

and update:

- `DB_HOST`
- `DB_NAME`
- `DB_USER`
- `DB_PASS`
- `APP_BASE_URL`

Example:

```php
const DB_HOST = 'localhost';
const DB_NAME = 'college_thinkgreen';
const DB_USER = 'college_api_user';
const DB_PASS = 'YOUR_PASSWORD';
const APP_BASE_URL = 'https://example.college.ac.il/thinkgreen';
```

## First smoke test

After upload, test these URLs in the browser:

```text
https://YOUR-DOMAIN/thinkgreen/api/index.php
https://YOUR-DOMAIN/thinkgreen/api/meta/health.php
```

If the API is alive, you should get JSON back.

## Admin setup

The admin endpoints require a user with `role = 'admin'`.

Recommended first-time setup:
1. Create a normal account through `auth/signup.php`
2. Open `users` in phpMyAdmin
3. Change that user's `role` from `user` to `admin`

## File permissions

Recommended defaults:
- folders: `755`
- files: `644`

If image upload fails, check that:

```text
public_html/thinkgreen/uploads/activities
```

is writable by the hosting environment.

## Endpoints you will use first

### Auth
- `auth/signup.php`
- `auth/login.php`
- `auth/request_reset_pin.php`
- `auth/verify_reset_pin.php`
- `auth/reset_password.php`
- `auth/logout.php`

### User
- `user/profile.php`
- `user/update_profile.php`
- `user/update_settings.php`
- `user/notifications.php`
- `user/app_connections.php`

### Activities
- `activities/create.php`
- `activities/list.php`

### Admin
- `admin/pending_activities.php`
- `admin/review_activity.php`

### Challenges
- `challenges/list.php`

### Rewards
- `rewards/catalog.php`
- `rewards/partner_businesses.php`
- `rewards/my_redemptions.php`
- `rewards/redeem.php`

### Meta/bootstrap
- `meta/bootstrap_data.php`
- `meta/health.php`

## Recommended deployment order

1. Import the SQL
2. Edit `config.php`
3. Upload `api/`
4. Upload `uploads/activities/.htaccess`
5. Test `meta/health.php`
6. Test `auth/signup.php`
7. Test `auth/login.php`
8. Connect Flutter to the API
