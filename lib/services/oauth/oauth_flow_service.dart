import 'package:flutter/foundation.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

import '../../config/api_config.dart';

class OAuthFlowException implements Exception {
  const OAuthFlowException(this.message);

  final String message;

  @override
  String toString() => message;
}

class OAuthFlowService {
  const OAuthFlowService();

  Future<String> authenticate(String authorizationUrl) async {
    final callbackUrl = await FlutterWebAuth2.authenticate(
      url: authorizationUrl,
      callbackUrlScheme: ApiConfig.oauthCallbackScheme,
      options: FlutterWebAuth2Options(
        windowName: kIsWeb ? Uri.base.resolve('auth.html').toString() : null,
      ),
    );

    final uri = Uri.parse(callbackUrl);
    final error =
        uri.queryParameters['message'] ?? uri.queryParameters['error'];
    if (error != null && error.trim().isNotEmpty) {
      throw OAuthFlowException(error.trim());
    }

    final handoffCode = uri.queryParameters['code'];
    if (handoffCode == null || handoffCode.trim().isEmpty) {
      throw const OAuthFlowException(
        'OAuth callback did not include a handoff code.',
      );
    }

    return handoffCode.trim();
  }
}
