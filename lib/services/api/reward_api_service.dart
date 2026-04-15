import 'api_client.dart';

class RewardApiService {
  RewardApiService(this._api);

  final ApiClient _api;

  Future<Map<String, dynamic>> fetchCatalog() {
    return _api.getJson('rewards/catalog.php');
  }

  Future<Map<String, dynamic>> fetchPartnerBusinesses() {
    return _api.getJson('rewards/partner_businesses.php');
  }

  Future<Map<String, dynamic>> fetchMyRedemptions() {
    return _api.getJson('rewards/my_redemptions.php');
  }

  Future<Map<String, dynamic>> redeemReward(String rewardPublicId) {
    return _api.postJson(
      'rewards/redeem.php',
      body: {'reward_public_id': rewardPublicId},
    );
  }
}
