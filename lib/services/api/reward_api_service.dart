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

  Future<Map<String, dynamic>> fetchAdminRewards() {
    return _api.getJson('admin/rewards.php');
  }

  Future<Map<String, dynamic>> createReward({
    required String title,
    required String description,
    required int pointsCost,
    required String emoji,
    required String partnerName,
  }) {
    return _api.postJson(
      'admin/rewards.php',
      body: {
        'title': title,
        'description': description,
        'points_cost': pointsCost,
        'emoji': emoji,
        'partner_name': partnerName,
      },
    );
  }

  Future<Map<String, dynamic>> updateReward({
    required String rewardPublicId,
    required String title,
    required String description,
    required int pointsCost,
    required String emoji,
    required String partnerName,
  }) {
    return _api.putJson(
      'admin/rewards.php',
      body: {
        'reward_public_id': rewardPublicId,
        'title': title,
        'description': description,
        'points_cost': pointsCost,
        'emoji': emoji,
        'partner_name': partnerName,
      },
    );
  }

  Future<Map<String, dynamic>> deleteReward(String rewardPublicId) {
    return _api.deleteJson(
      'admin/rewards.php',
      body: {'reward_public_id': rewardPublicId},
    );
  }
}
