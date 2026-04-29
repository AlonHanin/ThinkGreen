import 'dart:async';

import 'package:flutter/material.dart';

import '../models/app_connection.dart';
import '../services/api/api_exception.dart';
import '../services/api/api_payload_utils.dart';
import '../services/api/integration_api_service.dart';
import '../services/oauth/oauth_flow_service.dart';
import 'session_provider.dart';

class AppConnectionsProvider with ChangeNotifier {
  AppConnectionsProvider({
    required IntegrationApiService apiService,
    required OAuthFlowService oauthFlowService,
  }) : _apiService = apiService,
       _oauthFlowService = oauthFlowService;

  final IntegrationApiService _apiService;
  final OAuthFlowService _oauthFlowService;

  final Map<String, AppConnection> _connections = {};
  SessionProvider? _session;
  String? _lastBoundToken;
  bool _isLoading = false;
  bool _isActing = false;
  String? _lastError;

  bool get isLoading => _isLoading;
  bool get isActing => _isActing;
  String? get lastError => _lastError;

  AppConnection connectionFor(String provider) {
    final normalized = provider.trim().toLowerCase();
    return _connections[normalized] ??
        AppConnection(
          provider: normalized,
          status: AppConnectionStatus.disconnected,
        );
  }

  void bindSession(SessionProvider session) {
    _session = session;
    final token = session.authToken;

    if (!session.isAuthenticated ||
        session.isAdmin ||
        token == null ||
        token.isEmpty) {
      if (_connections.isNotEmpty || _lastBoundToken != null) {
        _connections.clear();
        _lastBoundToken = null;
        _lastError = null;
        notifyListeners();
      }
      return;
    }

    if (_lastBoundToken == token) return;
    _lastBoundToken = token;
    unawaited(refreshConnections());
  }

  Future<String?> refreshConnections() async {
    if (_session?.isAuthenticated != true || _session?.isAdmin == true) {
      return null;
    }

    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final payload = await _apiService.fetchConnections();
      final list = firstNestedList(payload, const [
        'connections',
        'items',
        'records',
        'data',
      ]);
      _connections
        ..clear()
        ..addEntries(
          list.map((item) {
            final connection = AppConnection.fromApi(item);
            return MapEntry(connection.provider, connection);
          }),
        );
      return null;
    } on ApiException catch (error) {
      _lastError = error.message;
      return error.message;
    } catch (_) {
      _lastError = 'Failed to load app connections.';
      return _lastError;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> connectProvider(String provider) async {
    return _runAction(() async {
      final payload = await _apiService.startOAuth(
        provider: provider,
        purpose: 'connect',
      );
      final authorizationUrl = firstString(payload, const [
        'authorization_url',
        'auth_url',
        'url',
      ]);
      if (authorizationUrl == null || authorizationUrl.isEmpty) {
        return 'Missing authorization URL.';
      }

      final handoffCode = await _oauthFlowService.authenticate(
        authorizationUrl,
      );
      final completedPayload = await _apiService.completeOAuth(handoffCode);
      final connectionMap = firstNestedMap(completedPayload, const [
        'connection',
      ]);
      if (connectionMap != null) {
        final connection = AppConnection.fromApi(connectionMap);
        _connections[connection.provider] = connection;
      } else {
        await refreshConnections();
      }

      return null;
    });
  }

  Future<String?> syncProvider(String provider) async {
    return _runAction(() async {
      final payload = await _apiService.syncProvider(provider);
      final connectionMap = firstNestedMap(payload, const ['connection']);
      if (connectionMap != null) {
        final connection = AppConnection.fromApi(connectionMap);
        _connections[connection.provider] = connection;
      } else {
        await refreshConnections();
      }
      return null;
    });
  }

  Future<String?> disconnectProvider(String provider) async {
    return _runAction(() async {
      final payload = await _apiService.disconnectProvider(provider);
      final connectionMap = firstNestedMap(payload, const ['connection']);
      if (connectionMap != null) {
        final connection = AppConnection.fromApi(connectionMap);
        _connections[connection.provider] = connection;
      } else {
        _connections.remove(provider.trim().toLowerCase());
      }
      return null;
    });
  }

  Future<String?> _runAction(Future<String?> Function() operation) async {
    _isActing = true;
    _lastError = null;
    notifyListeners();

    try {
      return await operation();
    } on OAuthFlowException catch (error) {
      _lastError = error.message;
      return error.message;
    } on ApiException catch (error) {
      _lastError = error.message;
      return error.message;
    } catch (_) {
      _lastError = 'Something went wrong. Please try again.';
      return _lastError;
    } finally {
      _isActing = false;
      notifyListeners();
    }
  }
}
