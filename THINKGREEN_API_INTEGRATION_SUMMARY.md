# Think Green – API integration summary

Updated for the uploaded V5 project.

## Main changes
- Connected auth screens to the real API provider flow (sign in, sign up, forgot password, verify PIN, reset password).
- Removed demo/prototype UI leftovers:
  - demo open button
  - demo user label
  - prototype PIN text
  - hardcoded user/demo names
- Connected profile editing to the API-backed `SessionProvider`.
- Connected manual report submission to `ActivityProvider.submitManualActivity(...)`.
- Connected admin approvals to async approve/reject API calls and pending list refresh.
- Connected rewards redemption to async API flow.
- Improved rewards/challenges/loading states in the UI.
- Changed admin access from client-side hardcoded code flow to admin account sign-in flow.
- Splash screen now routes to home when a session is already active in memory.

## Important note
Some API endpoint response shapes were handled defensively because the live server payload could not be inspected from this environment during the patch session. To reduce breakage risk, parsing now supports multiple common field names and nesting patterns.

## Recommended local checks
1. `flutter pub get`
2. `flutter analyze`
3. `flutter run -d chrome`
4. Verify these flows end-to-end:
   - user sign up
   - user sign in
   - forgot password -> PIN -> reset password
   - edit profile
   - manual report submit
   - admin login with a real admin account
   - admin approve/reject
   - rewards list / redeem / active rewards
   - challenges screen loading/progress
