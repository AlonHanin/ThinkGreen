import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/green_activity.dart';
import '../services/api/activity_api_service.dart';
import '../services/api/api_exception.dart';
import '../services/api/api_payload_utils.dart';
import 'session_provider.dart';

class ActivityProvider with ChangeNotifier {
  ActivityProvider({required ActivityApiService apiService}) : _apiService = apiService;

  final ActivityApiService _apiService;

  final List<GreenActivity> _activities = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _isReviewing = false;
  String? _lastError;
  String? _lastBoundToken;
  ActivityStatus? _lastSubmittedStatus;
  SessionProvider? _session;

  List<GreenActivity> get activities => List.unmodifiable(_activities);
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  bool get isReviewing => _isReviewing;
  String? get lastError => _lastError;
  ActivityStatus? get lastSubmittedStatus => _lastSubmittedStatus;

  List<GreenActivity> get approvedActivities =>
      _activities.where((activity) => activity.status == ActivityStatus.approved).toList(growable: false);

  List<GreenActivity> get pendingActivities =>
      _activities.where((activity) => activity.status == ActivityStatus.pending).toList(growable: false);

  List<GreenActivity> get rejectedActivities =>
      _activities.where((activity) => activity.status == ActivityStatus.rejected).toList(growable: false);

  int get totalPoints => approvedActivities.fold(0, (sum, activity) => sum + activity.points);

  void bindSession(SessionProvider session) {
    _session = session;
    final token = session.authToken;

    if (!session.isAuthenticated || session.isAdmin || token == null || token.isEmpty) {
      if (_activities.isNotEmpty || _lastBoundToken != null) {
        _activities.clear();
        _lastError = null;
        _lastBoundToken = null;
        notifyListeners();
      }
      return;
    }

    if (_lastBoundToken == token) return;
    _lastBoundToken = token;
    unawaited(refreshActivities());
  }

  List<GreenActivity> recentActivities({int limit = 5}) {
    final copy = [..._activities]..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return copy.take(limit).toList(growable: false);
  }

  Future<String?> refreshActivities() async {
    if (_session?.isAuthenticated != true || _session?.isAdmin == true) return null;

    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final payload = await _apiService.fetchActivities();
      final parsed = _parseActivitiesFromPayload(payload);
      _activities
        ..clear()
        ..addAll(parsed);
      _activities.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      return null;
    } on ApiException catch (error) {
      if (error.statusCode == 401) {
        _activities.clear();
        _lastError = null;
        return null;
      }
      _lastError = error.message;
      return error.message;
    } catch (_) {
      _lastError = 'Failed to load activities.';
      return _lastError;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> loadPendingActivities() async {
    if (_session?.isAuthenticated != true) return null;

    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final payload = await _apiService.fetchPendingActivities();
      final parsed = _parseActivitiesFromPayload(payload);
      final pendingIds = parsed.map((e) => e.id).toSet();
      _activities.removeWhere((activity) => activity.status == ActivityStatus.pending && pendingIds.contains(activity.id));
      for (final activity in parsed) {
        final index = _activities.indexWhere((item) => item.id == activity.id);
        if (index == -1) {
          _activities.add(activity);
        } else {
          _activities[index] = activity;
        }
      }
      _activities.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      return null;
    } on ApiException catch (error) {
      if (error.statusCode == 401) {
        _activities.clear();
        _lastError = null;
        return null;
      }
      _lastError = error.message;
      return error.message;
    } catch (_) {
      _lastError = 'Failed to load pending activities.';
      return _lastError;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> submitManualActivity({
    required String activityTitle,
    required DateTime dateTime,
    Uint8List? imageBytes,
    String? filename,
  }) async {
    if (_session?.isAuthenticated != true) {
      return 'Please sign in first.';
    }

    _isSubmitting = true;
    _lastError = null;
    _lastSubmittedStatus = null;
    notifyListeners();

    try {
      final payload = await _apiService.createManualActivity(
        activitySlug: _slugForActivity(activityTitle),
        source: 'manual',
        activityDateTime: DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime),
        imageBytes: imageBytes,
        filename: filename,
      );

      final createdMap = firstNestedMap(payload, const ['activity', 'item', 'record']);
      if (createdMap != null) {
        final parsed = GreenActivity.fromApi(createdMap);
        final created = parsed.copyWith(
          userName: parsed.userName ?? _session?.currentUser.fullName,
          imageBytes: imageBytes,
        );
        _lastSubmittedStatus = created.status;
        final index = _activities.indexWhere((item) => item.id == created.id);
        if (index == -1) {
          _activities.insert(0, created);
        } else {
          _activities[index] = created;
        }
      } else {
        await refreshActivities();
        _lastSubmittedStatus = firstString(payload, const ['status']) == 'approved'
            ? ActivityStatus.approved
            : ActivityStatus.pending;
      }

      _activities.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      return null;
    } on ApiException catch (error) {
      _lastError = error.message;
      return error.message;
    } catch (_) {
      _lastError = 'Failed to submit activity.';
      return _lastError;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<String?> approveActivity(String id, {String? reviewNotes}) {
    return _reviewActivity(id: id, action: 'approve', reviewNotes: reviewNotes);
  }

  Future<String?> rejectActivity(String id, {String? reviewNotes}) {
    return _reviewActivity(id: id, action: 'reject', reviewNotes: reviewNotes);
  }

  Future<String?> _reviewActivity({
    required String id,
    required String action,
    String? reviewNotes,
  }) async {
    _isReviewing = true;
    _lastError = null;
    notifyListeners();

    try {
      final payload = await _apiService.reviewActivity(
        activityId: id,
        action: action,
        reviewNotes: reviewNotes,
      );

      final reviewedMap = firstNestedMap(payload, const ['activity', 'item', 'record']);
      if (reviewedMap != null) {
        final reviewed = GreenActivity.fromApi(reviewedMap);
        final index = _activities.indexWhere((item) => item.id == id || item.id == reviewed.id);
        if (index != -1) {
          _activities[index] = reviewed.copyWith(imageBytes: _activities[index].imageBytes);
        }
      } else {
        final index = _activities.indexWhere((item) => item.id == id);
        if (index != -1) {
          _activities[index] = _activities[index].copyWith(
            status: action == 'approve' ? ActivityStatus.approved : ActivityStatus.rejected,
          );
        }
      }

      _activities.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      return null;
    } on ApiException catch (error) {
      _lastError = error.message;
      return error.message;
    } catch (_) {
      _lastError = 'Failed to review activity.';
      return _lastError;
    } finally {
      _isReviewing = false;
      notifyListeners();
    }
  }

  List<GreenActivity> _parseActivitiesFromPayload(Map<String, dynamic> payload) {
    final list = firstNestedList(payload, const [
      'activities',
      'items',
      'records',
      'pending_activities',
      'data',
    ]);
    return list.map(GreenActivity.fromApi).toList(growable: false);
  }

  String _slugForActivity(String title) {
    switch (title.trim()) {
      case 'Recycled Plastic Bottles':
        return 'recycled_plastic_bottles';
      case 'Used Public Transport':
        return 'used_public_transport';
      case 'Used A Reusable Bottle':
        return 'used_reusable_bottle';
      case 'Walked / Biked to Work':
        return 'walked_biked_to_work';
      default:
        return title
            .trim()
            .toLowerCase()
            .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
            .replaceAll(RegExp(r'_+'), '_')
            .replaceAll(RegExp(r'^_|_$'), '');
    }
  }
}
