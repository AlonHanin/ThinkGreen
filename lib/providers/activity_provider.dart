import 'package:flutter/material.dart';
import '../models/green_activity.dart';

class ActivityProvider extends ChangeNotifier {
  final List<GreenActivity> _activities = [
    GreenActivity(
      title: 'Recycled Plastic Bottles',
      source: ActivitySource.manual,
      dateTime: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      points: 20,
    ),
    GreenActivity(
      title: 'Walked 4.1 Km',
      source: ActivitySource.strava,
      dateTime: DateTime.now().subtract(const Duration(days: 1)),
      points: 15,
    ),
    GreenActivity(
      title: 'Bus Ride Instead Of Car (Tel Aviv -> Rishon)',
      source: ActivitySource.moovit,
      dateTime: DateTime.now().subtract(const Duration(hours: 5)),
      points: 25,
    ),
  ];

  List<GreenActivity> get activities => _activities;

  int get totalPoints => _activities.fold(0, (sum, item) => sum + item.points);

  void addActivity(GreenActivity activity) {
    _activities.insert(0, activity);
    notifyListeners();
  }
}
