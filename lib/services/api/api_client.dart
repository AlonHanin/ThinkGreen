import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  String? _token;

  void setToken(String? token) => _token = token;

  Future<Map<String, dynamic>> getJson(String path) async {
    ApiConfig.debugAssertConfigured();
    final response = await _client.get(
      _uri(path),
      headers: _headers(),
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    ApiConfig.debugAssertConfigured();
    final response = await _client.post(
      _uri(path),
      headers: _headers(json: true),
      body: jsonEncode(body),
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required Map<String, String> fields,
    Uint8List? fileBytes,
    String fileField = 'image',
    String? filename,
    String? contentType,
  }) async {
    ApiConfig.debugAssertConfigured();
    final request = http.MultipartRequest('POST', _uri(path));
    request.headers.addAll(_headers());
    request.fields.addAll(fields);

    if (fileBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          fileField,
          fileBytes,
          filename: filename ?? 'activity.jpg',
        ),
      );
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    return _decode(response);
  }

  Uri _uri(String path) {
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    return Uri.parse('${ApiConfig.baseUrl}/$normalizedPath');
  }

  Map<String, String> _headers({bool json = false}) {
    final headers = <String, String>{};
    if (json) {
      headers['Content-Type'] = 'application/json';
    }
    if (_token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Map<String, dynamic> _decode(http.Response response) {
    final Map<String, dynamic> payload;
    if (response.body.isEmpty) {
      payload = <String, dynamic>{};
    } else {
      try {
        payload = jsonDecode(response.body) as Map<String, dynamic>;
      } on FormatException {
        throw ApiException(
          'HTTP ${response.statusCode}: ${response.reasonPhrase ?? 'Unexpected server response.'}',
          statusCode: response.statusCode,
        );
      }
    }

    final success = payload['success'] == true;
    if (!success) {
      throw ApiException(
        payload['message']?.toString() ??
            'HTTP ${response.statusCode}: ${response.reasonPhrase ?? 'API request failed.'}',
        statusCode: response.statusCode,
      );
    }

    return payload;
  }
}
