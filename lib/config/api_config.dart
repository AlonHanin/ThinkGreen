import 'package:flutter/foundation.dart';

class ApiConfig {
  /// Example:
  /// static const String baseUrl = 'https://your-domain.example/thinkgreen/api';
  static const String baseUrl =
      'http://islidorav.mtacloud.co.il/thinkgreen/api';
  static const String oauthCallbackScheme = 'thinkgreen';

  static bool get isConfigured => !baseUrl.contains('YOUR-DOMAIN');

  static void debugAssertConfigured() {
    if (kDebugMode && !isConfigured) {
      debugPrint(
        'ApiConfig.baseUrl is still using the placeholder. '
        'Update lib/config/api_config.dart before calling the live API.',
      );
    }
  }
}
