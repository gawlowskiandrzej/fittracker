import 'package:cloud_firestore/cloud_firestore.dart';

class Activity {
  final String id;
  final String type;
  final double distanceKm;
  final int steps;
  final int durationMinutes;
  final DateTime startTime;

  Activity({
    required this.id,
    required this.type,
    required this.distanceKm,
    required this.steps,
    required this.durationMinutes,
    required this.startTime,
  });

  factory Activity.fromFirestore(Map<String, dynamic> data, String id) {
    return Activity(
      id: id,
      type: data['type'] ?? 'unknown',
      distanceKm: (data['distanceKm'] ?? 0).toDouble(),
      steps: data['steps'] ?? 0,
      durationMinutes: data['durationMinutes'] ?? 0,
      startTime: (data['startTime'] as Timestamp).toDate(),
    );
  }
}
