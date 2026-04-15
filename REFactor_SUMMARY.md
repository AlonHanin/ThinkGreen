# Think Green – Refactor Summary

Updated on: 2026-04-09

## What was fixed

### Core architecture
- Added `SessionProvider` to centralize demo user/session/settings state.
- Added `RewardProvider` to centralize rewards catalog, point balance and active redemptions.
- Converted `ChallengeProvider` to sync progress automatically from approved activities.
- Updated `main.dart` to wire providers through `ChangeNotifierProxyProvider`.

### Broken flows repaired
- Fixed `GreenActivity` model so image paths are stored consistently via `imageUrl`.
- Rebuilt forgot-password flow:
  - `ForgotPasswordScreen`
  - `SecurityPinScreen`
  - `ResetPasswordScreen`
- Added validation for Sign In / Sign Up instead of `debugPrint` placeholders.
- Replaced visible hardcoded admin password in UI with a configured access code stored in provider logic.

### Rewards system
- Removed hardcoded points from `RedeemScreen`.
- Added real point balance based on approved activities.
- Implemented reward redemption.
- Added active rewards list with QR flow.
- Connected partner businesses to the same provider-driven reward data.

### Activity flow
- Manual report now:
  - validates required fields
  - stores current user name
  - saves image path correctly
  - routes auto-verified items to approved
  - routes non-verified items to pending
- Admin review now supports approve/reject feedback cleanly.
- Activity history now shows status badges.

### Profile and settings
- Removed hardcoded profile name / email / ID display values from screens.
- Connected edit profile to provider state.
- Connected settings toggles to shared state.
- Added language selection sheet.
- Added terms dialog.

### UX cleanup
- Replaced dead notification/help/actions with either real flow or explicit placeholder feedback.
- Added Sync Apps entry back into the activities menu.
- Added admin statistics dialog.
- Added challenge CTA that routes users to activities instead of doing nothing.

## Demo credentials currently configured
- Demo user email: `alon@thinkgreen.app`
- Demo user password: `GreenPass123`
- Demo security PIN: `2468`
- Demo admin access code: `TG-ADMIN-2026`

## Important note before production / DB connection
These values are intentionally still mock/demo data and should be replaced by server-side auth, secure reset tokens, and persistent storage once you connect the real backend.
