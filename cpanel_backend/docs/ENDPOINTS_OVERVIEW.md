# Think Green – endpoint contract

## Authentication model
The API uses a **Bearer token** stored in the `auth_tokens` table.

Send this header after login:

```http
Authorization: Bearer YOUR_TOKEN
```

## Auth examples

### POST auth/signup.php
JSON body:
```json
{
  "full_name": "Alon Hanin",
  "email": "alon@example.com",
  "phone": "0501234567",
  "date_of_birth": "1995-03-12",
  "password": "GreenPass123",
  "confirm_password": "GreenPass123",
  "locale": "he"
}
```

### POST auth/login.php
```json
{
  "email": "alon@example.com",
  "password": "GreenPass123"
}
```

### OAuth flows
These flows are used by the Flutter app for:
- `Google` sign-in / sign-up
- `Strava` connect + sync

### POST oauth/start.php
Examples:

Google login:
```json
{
  "provider": "google",
  "purpose": "login"
}
```

Strava connect:
```json
{
  "provider": "strava",
  "purpose": "connect"
}
```

### POST oauth/complete.php
```json
{
  "handoff_code": "OAUTH_HANDOFF_CODE"
}
```

### POST user/sync_app.php
```json
{
  "provider": "strava"
}
```

### POST user/disconnect_app.php
```json
{
  "provider": "strava"
}
```

## Create activity with image
Use **multipart/form-data**:

Fields:
- `activity_definition_slug`
- `source`
- `activity_datetime`
- `client_verified`
- `status`
- `image`

Example slugs:
- `recycled_plastic_bottles`
- `used_public_transport`
- `used_reusable_bottle`
- `walked_biked_to_work`

## Approve or reject activity
### POST admin/review_activity.php
```json
{
  "activity_id": 12,
  "action": "approve",
  "review_notes": "Looks good"
}
```

or

```json
{
  "activity_id": 12,
  "action": "reject",
  "review_notes": "Image is unclear"
}
```

## Important business rules already implemented in PHP

### On activity approval
The backend automatically:
1. marks the activity as approved
2. inserts an `activity_approved` row into `points_ledger`
3. recalculates the user balance
4. syncs `user_challenges`
5. grants the challenge bonus once if a challenge was just completed

### On reward redemption
The backend automatically:
1. checks available points
2. creates a redemption record
3. inserts a negative ledger row
4. recalculates the user balance

This is the server-side equivalent of the logic you already built in Flutter.
