import '../services/api/api_payload_utils.dart';

class Challenge {
  final String id;
  final String title;
  final String description;
  final int points;
  final String icon;
  final int targetCount;
  int currentCount;
  final DateTime endDate;
  final List<String> trackingKeywords;
  final String linkedActivityTitle;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.targetCount,
    this.currentCount = 0,
    required this.endDate,
    this.icon = '🏆',
    this.trackingKeywords = const [],
    required this.linkedActivityTitle,
  });

  factory Challenge.fromApi(Map<String, dynamic> map) {
    final target = firstInt(map, const ['target_count', 'targetCount', 'target', 'goal']) ?? 1;
    return Challenge(
      id: firstString(map, const ['public_id', 'id', 'challenge_id']) ?? '',
      title: firstString(map, const ['title', 'name']) ?? 'Challenge',
      description: firstString(map, const ['description', 'subtitle']) ?? '',
      points: firstInt(map, const ['points_bonus', 'bonus_points', 'points', 'reward_points']) ?? 0,
      targetCount: target <= 0 ? 1 : target,
      currentCount: firstInt(map, const ['progress_count', 'current_count', 'currentCount']) ?? 0,
      endDate: firstDateTime(map, const ['ends_at', 'end_date', 'endDate', 'expires_at']) ??
          DateTime.now().add(const Duration(days: 7)),
      icon: firstString(map, const ['icon', 'emoji']) ?? '🏆',
      trackingKeywords: _parseKeywords(map),
      linkedActivityTitle: firstString(
            map,
            const ['linked_activity_title', 'activity_title', 'activity_definition_title', 'title'],
          ) ??
          firstString(map, const ['title', 'name']) ??
          'Activity',
    );
  }

  double get progress => (currentCount / targetCount).clamp(0.0, 1.0);

  bool get isCompleted => currentCount >= targetCount;

  int get daysLeft {
    final days = endDate.difference(DateTime.now()).inDays;
    return days < 0 ? 0 : days;
  }

  static List<String> _parseKeywords(Map<String, dynamic> map) {
    final raw = deepFind(map, 'tracking_keywords') ?? deepFind(map, 'keywords');
    if (raw is List) {
      return raw.map((item) => item.toString()).toList(growable: false);
    }
    return const [];
  }
}
