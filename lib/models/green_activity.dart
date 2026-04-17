import 'dart:typed_data';

import 'package:uuid/uuid.dart';

import '../services/api/api_payload_utils.dart';

enum ActivitySource { manual, strava, moovit }
enum ActivityStatus { pending, approved, rejected }

class GreenActivity {
  final String id;
  final String title;
  final ActivitySource source;
  final DateTime dateTime;
  final int points;
  final String? imageUrl;
  final Uint8List? imageBytes;
  final String? userName;
  ActivityStatus status;

  GreenActivity({
    String? id,
    required this.title,
    required this.source,
    required this.dateTime,
    required this.points,
    this.imageUrl,
    this.imageBytes,
    this.userName,
    this.status = ActivityStatus.pending,
  }) : id = id ?? const Uuid().v4();

  factory GreenActivity.fromApi(Map<String, dynamic> map) {
    return GreenActivity(
      id: firstString(map, const ['id', 'activity_id', 'public_id']) ?? const Uuid().v4(),
      title: firstString(map, const ['title_snapshot', 'title', 'activity_title', 'name']) ?? 'Activity',
      source: _parseSource(firstString(map, const ['source', 'activity_source']) ?? 'manual'),
      dateTime: firstDateTime(
            map,
            const ['occurred_at', 'activity_datetime', 'submitted_at', 'created_at', 'date_time'],
          ) ??
          DateTime.now(),
      points: firstInt(map, const ['points_awarded', 'points', 'default_points', 'reward_points']) ?? 0,
      imageUrl: firstString(
        map,
        const ['image_url', 'proof_image_url', 'photo_url', 'image_path', 'attachment_url'],
      ),
      userName: firstString(map, const ['user_name', 'full_name', 'submitted_by', 'name']),
      status: _parseStatus(firstString(map, const ['status', 'activity_status']) ?? 'pending'),
    );
  }

  GreenActivity copyWith({
    String? id,
    String? title,
    ActivitySource? source,
    DateTime? dateTime,
    int? points,
    String? imageUrl,
    Uint8List? imageBytes,
    String? userName,
    ActivityStatus? status,
  }) {
    return GreenActivity(
      id: id ?? this.id,
      title: title ?? this.title,
      source: source ?? this.source,
      dateTime: dateTime ?? this.dateTime,
      points: points ?? this.points,
      imageUrl: imageUrl ?? this.imageUrl,
      imageBytes: imageBytes ?? this.imageBytes,
      userName: userName ?? this.userName,
      status: status ?? this.status,
    );
  }

  static ActivitySource _parseSource(String value) {
    switch (value.trim().toLowerCase()) {
      case 'strava':
        return ActivitySource.strava;
      case 'moovit':
        return ActivitySource.moovit;
      default:
        return ActivitySource.manual;
    }
  }

  static ActivityStatus _parseStatus(String value) {
    switch (value.trim().toLowerCase()) {
      case 'approved':
        return ActivityStatus.approved;
      case 'rejected':
        return ActivityStatus.rejected;
      default:
        return ActivityStatus.pending;
    }
  }
}
