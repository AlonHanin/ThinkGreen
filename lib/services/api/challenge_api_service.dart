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
}
