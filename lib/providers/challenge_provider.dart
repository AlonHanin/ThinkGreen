import 'dart:async';

import 'package:flutter/material.dart';

import '../models/challenge.dart';
import '../services/api/api_exception.dart';
import '../services/api/api_payload_utils.dart';
import '../services/api/challenge_api_service.dart';
import 'session_provider.dart';

class ChallengeProvider with ChangeNotifier {
  ChallengeProvider({required ChallengeApiService apiService}) : _apiService = apiService;

  final ChallengeApiService _apiService;

  final List<Challenge> _challenges = [];
  bool _isLoading = false;
  String? _lastError;
  String? _lastBoundToken;

  List<Challenge> get challenges => List.unmodifiable(_challenges);
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;

  List<Challenge> get completedChallenges =>
      _challenges.where((challenge) => challenge.isCompleted).toList(growable: false);

  int get totalBonusPoints => completedChallenges.fold(0, (sum, challenge) => sum + challenge.points);

  void bindSession(SessionProvider session) {
    final token = session.authToken;
    if (!session.isAuthenticated || session.isAdmin || token == null || token.isEmpty) {
      if (_challenges.isNotEmpty || _lastBoundToken != null) {
        _challenges.clear();
        _lastError = null;
        _lastBoundToken = null;
        notifyListeners();
      }
      return;
    }

    if (_lastBoundToken == token) return;
    _lastBoundToken = token;
    unawaited(refreshChallenges());
  }

  Future<String?> refreshChallenges() async {
    if (_lastBoundToken == null) return null;

    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final payload = await _apiService.fetchChallenges();
      var parsed = _parseChallenges(payload);
      if (parsed.isEmpty) {
        final bootstrapPayload = await _apiService.fetchBootstrapData();
        parsed = _parseChallenges(bootstrapPayload);
      }
      _challenges
        ..clear()
        ..addAll(parsed);
      return null;
    } on ApiException catch (error) {
      if (error.statusCode == 401) {
        _challenges.clear();
        _lastError = null;
        return null;
      }
      _lastError = error.message;
      return error.message;
    } catch (_) {
      _lastError = 'Failed to load challenges.';
      return _lastError;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }



  Future<String?> addChallenge(Challenge challenge) async {
    _challenges.insert(0, challenge);
    notifyListeners();
    return null;
  }

  void syncFromActivities(List<dynamic> _) {
    // Progress is now expected to come from the API.
  }

  List<Challenge> _parseChallenges(Map<String, dynamic> payload) {
    final list = firstNestedList(payload, const ['challenges', 'items', 'records', 'data']);
    return list.map(Challenge.fromApi).toList(growable: false);
  }
}
