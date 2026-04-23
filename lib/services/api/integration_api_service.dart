import 'api_client.dart';

class IntegrationApiService {
  IntegrationApiService(this._api);

  final ApiClient _api;

  Future<Map<String, dynamic>> startOAuth({
    required String provider,
    required String purpose,
  }) {
    return _api.postJson(
      'oauth/start.php',
      body: {'provider': provider, 'purpose': purpose},
    );
  }

  Future<Map<String, dynamic>> completeOAuth(String handoffCode) {
    return _api.postJson(
      'oauth/complete.php',
      body: {'handoff_code': handoffCode},
    );
  }

  Future<Map<String, dynamic>> fetchConnections() {
    return _api.getJson('user/app_connections.php');
  }

  Future<Map<String, dynamic>> syncProvider(String provider) {
    return _api.postJson('user/sync_app.php', body: {'provider': provider});
  }

  Future<Map<String, dynamic>> disconnectProvider(String provider) {
    return _api.postJson(
      'user/disconnect_app.php',
      body: {'provider': provider},
    );
  }
}
