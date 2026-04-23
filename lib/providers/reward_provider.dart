import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../models/reward_item.dart';
import '../services/api/api_exception.dart';
import '../services/api/api_payload_utils.dart';
import '../services/api/reward_api_service.dart';
import 'session_provider.dart';

class RewardProvider with ChangeNotifier {
  RewardProvider({required RewardApiService apiService}) : _apiService = apiService;

  final RewardApiService _apiService;

  final List<RewardItem> _catalog = [];
  final List<PartnerBusiness> _partnerBusinesses = [];
  final List<RewardRedemption> _activeRedemptions = [];

  int _earnedPoints = 0;
  int? _serverAvailablePoints;
  bool _isLoading = false;
  bool _isRedeeming = false;
  String? _lastError;
  String? _lastBoundToken;

  List<RewardItem> get catalog => List.unmodifiable(_catalog);
  List<PartnerBusiness> get partnerBusinesses => List.unmodifiable(_partnerBusinesses);
  List<RewardRedemption> get activeRedemptions => List.unmodifiable(_activeRedemptions.reversed.toList());
  int get earnedPoints => _serverAvailablePoints ?? _earnedPoints;
  bool get isLoading => _isLoading;
  bool get isRedeeming => _isRedeeming;
  String? get lastError => _lastError;

  int get spentPoints => _activeRedemptions.fold(0, (sum, item) => sum + item.reward.cost);

  int get availablePoints {
    if (_serverAvailablePoints != null) {
      return max(_serverAvailablePoints!, 0);
    }
    return max(_earnedPoints - spentPoints, 0);
  }

  int get nextRewardThreshold {
    final thresholds = _catalog.map((reward) => reward.cost).toSet().toList()..sort();
    for (final threshold in thresholds) {
      if (threshold > availablePoints) return threshold;
    }
    return thresholds.isEmpty ? 0 : thresholds.last;
  }

  double get progressToNextReward {
    final next = nextRewardThreshold;
    if (next == 0) return 1;
    return (availablePoints / next).clamp(0.0, 1.0);
  }

  void bindSession(SessionProvider session) {
    final token = session.authToken;
    if (!session.isAuthenticated || session.isAdmin || token == null || token.isEmpty) {
      if (_catalog.isNotEmpty || _partnerBusinesses.isNotEmpty || _activeRedemptions.isNotEmpty || _lastBoundToken != null) {
        _catalog.clear();
        _partnerBusinesses.clear();
        _activeRedemptions.clear();
        _serverAvailablePoints = null;
        _lastError = null;
        _lastBoundToken = null;
        notifyListeners();
      }
      return;
    }

    if (_lastBoundToken == token) return;
    _lastBoundToken = token;
    unawaited(refresh());
  }

  Future<String?> refresh() async {
    if (_lastBoundToken == null) return null;

    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final catalogPayload = await _apiService.fetchCatalog();
      final partnersPayload = await _apiService.fetchPartnerBusinesses();
      final redemptionsPayload = await _apiService.fetchMyRedemptions();

      _catalog
        ..clear()
        ..addAll(_parseCatalog(catalogPayload));
      _partnerBusinesses
        ..clear()
        ..addAll(_parsePartners(partnersPayload));
      _activeRedemptions
        ..clear()
        ..addAll(_parseRedemptions(redemptionsPayload));

      _serverAvailablePoints = extractPointsBalance(catalogPayload) ??
          extractPointsBalance(redemptionsPayload) ??
          extractPointsBalance(partnersPayload) ??
          _serverAvailablePoints;

      return null;
    } on ApiException catch (error) {
      if (error.statusCode == 401) {
        _catalog.clear();
        _partnerBusinesses.clear();
        _activeRedemptions.clear();
        _serverAvailablePoints = null;
        _lastError = null;
        return null;
      }
      _lastError = error.message;
      return error.message;
    } catch (_) {
      _lastError = 'Failed to load rewards.';
      return _lastError;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void syncEarnedPoints({
    required int totalApprovedPoints,
    required int challengeBonusPoints,
  }) {
    if (_serverAvailablePoints != null) return;
    final total = totalApprovedPoints + challengeBonusPoints;
    if (_earnedPoints == total) return;
    _earnedPoints = total;
    notifyListeners();
  }

  Future<String?> redeemReward(RewardItem reward) async {
    if (availablePoints < reward.cost) {
      return 'Not enough points to redeem this reward yet.';
    }

    _isRedeeming = true;
    _lastError = null;
    notifyListeners();

    try {
      final payload = await _apiService.redeemReward(reward.id);
      final redemptionMap = firstNestedMap(payload, const ['redemption', 'item', 'record']);
      if (redemptionMap != null) {
        _activeRedemptions.add(RewardRedemption.fromApi(redemptionMap, reward: reward));
      }
      _serverAvailablePoints = extractPointsBalance(payload) ??
          (_serverAvailablePoints != null ? _serverAvailablePoints! - reward.cost : null);
      await refresh();
      return null;
    } on ApiException catch (error) {
      _lastError = error.message;
      return error.message;
    } catch (_) {
      _lastError = 'Failed to redeem reward.';
      return _lastError;
    } finally {
      _isRedeeming = false;
      notifyListeners();
    }
  }

  String qrPayloadFor(RewardRedemption redemption) {
    return 'thinkgreen://reward/${redemption.redemptionCode}/${redemption.reward.id}';
  }

  List<RewardItem> _parseCatalog(Map<String, dynamic> payload) {
    final list = firstNestedList(payload, const ['rewards', 'catalog', 'items', 'records', 'data']);
    return list.map(RewardItem.fromApi).toList(growable: false);
  }

  List<PartnerBusiness> _parsePartners(Map<String, dynamic> payload) {
    final list = firstNestedList(payload, const [
      'partner_businesses',
      'partners',
      'items',
      'records',
      'data',
    ]);
    return list.map(PartnerBusiness.fromApi).toList(growable: false);
  }

  List<RewardRedemption> _parseRedemptions(Map<String, dynamic> payload) {
    final list = firstNestedList(payload, const [
      'active_redemptions',
      'redemptions',
      'my_redemptions',
      'items',
      'records',
      'data',
    ]);
    return list.map((item) => RewardRedemption.fromApi(item)).toList(growable: false);
  }
}
