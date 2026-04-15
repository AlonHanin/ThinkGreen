# Think Green – Flutter API integration notes

These files are intentionally **non-invasive**.  
They do not change your working V4.1 UI yet.

## What to do
Copy the `lib/config` and `lib/services/api` folders into your Flutter project.

## Then update
1. `lib/config/api_config.dart`  
   Replace the placeholder base URL with your real cPanel API URL.

2. `SessionProvider`
   Replace local `signIn/signUp/resetPassword/updateProfile` logic with async calls to `AuthApiService`.

3. `ActivityProvider`
   Replace local list mutation with:
   - `fetchActivities()`
   - `createManualActivity()`
   - `fetchPendingActivities()`
   - `reviewActivity()`

4. `ChallengeProvider`
   Replace local challenge seed data with `fetchChallenges()`.

5. `RewardProvider`
   Replace seeded reward catalog and active redemptions with:
   - `fetchCatalog()`
   - `fetchMyRedemptions()`
   - `redeemReward()`

## Why this is safer
Your current V4.1 app already works.  
So the best move is to first deploy the backend and verify the endpoints, then switch the Flutter providers one by one instead of replacing everything in one jump.

## Suggested integration order
1. Login + Sign up
2. Profile load/update
3. Activity submit + activity history
4. Admin approvals
5. Challenges
6. Rewards
