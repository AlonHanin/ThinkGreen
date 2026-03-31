import 'package:uuid/uuid.dart';

enum ActivitySource { manual, strava, moovit }

class GreenActivity {
  final String id;
  final String title;
  final ActivitySource source;
  final DateTime dateTime;
  final int points;

  GreenActivity({
    String? id,
    required this.title,
    required this.source,
    required this.dateTime,
    required this.points,
  }) : id = id ?? const Uuid().v4();
}
