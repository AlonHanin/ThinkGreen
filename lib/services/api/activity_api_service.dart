import 'dart:typed_data';

import 'api_client.dart';

class ActivityApiService {
  ActivityApiService(this._api);

  final ApiClient _api;

  Future<Map<String, dynamic>> fetchActivities() {
    return _api.getJson('activities/list.php');
  }

  Future<Map<String, dynamic>> createManualActivity({
    required String activitySlug,
    required String source,
    required String activityDateTime,
    required bool clientVerified,
    required String requestedStatus,
    Uint8List? imageBytes,
    String? filename,
  }) {
    return _api.postMultipart(
      'activities/create.php',
      fields: {
        'activity_definition_slug': activitySlug,
        'source': source,
        'activity_datetime': activityDateTime,
        'client_verified': clientVerified ? '1' : '0',
        'status': requestedStatus,
      },
      fileBytes: imageBytes,
      filename: filename ?? 'activity.jpg',
    );
  }

  Future<Map<String, dynamic>> fetchPendingActivities() {
    return _api.getJson('admin/pending_activities.php');
  }

  Future<Map<String, dynamic>> reviewActivity({
    required String activityId,
    required String action,
    String? reviewNotes,
  }) {
    return _api.postJson(
      'admin/review_activity.php',
      body: {
        'activity_id': activityId,
        'action': action,
        'review_notes': reviewNotes ?? '',
      },
    );
  }
}
