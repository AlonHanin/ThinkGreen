import 'api_client.dart';

class ChallengeApiService {
  ChallengeApiService(this._api);

  final ApiClient _api;

  Future<Map<String, dynamic>> fetchChallenges() {
    return _api.getJson('challenges/list.php');
  }

  Future<Map<String, dynamic>> fetchBootstrapData() {
    return _api.getJson('meta/bootstrap_data.php');
  }

  Future<Map<String, dynamic>> createChallenge({
    required String title,
    required String description,
    required String icon,
    required int pointsBonus,
    required int targetCount,
    required DateTime endDate,
    required String linkedActivityTitle,
  }) {
    return _api.postJson(
      'admin/create_challenge.php',
      body: {
        'title': title,
        'description': description,
        'icon': icon,
        'points_bonus': pointsBonus,
        'target_count': targetCount,
        'end_date': endDate.toUtc().toIso8601String(),
        'linked_activity_title': linkedActivityTitle,
      },
    );
  }
}
