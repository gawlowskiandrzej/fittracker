import 'package:cloud_firestore/cloud_firestore.dart';

class Activity {
  final String id;
  final String userId;
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
    required this.userId
  });

  factory Activity.fromFirestore(Map<String, dynamic> data, String id) {
    return Activity(
      id: id,
      userId: data['userId'] ?? '-1',
      type: data['type'] ?? 'unknown',
      distanceKm: (data['distanceKm'] ?? 0).toDouble(),
      steps: data['steps'] ?? 0,
      durationMinutes: data['durationMinutes'] ?? 0,
      startTime: (data['startTime'] as Timestamp).toDate(),
    );
  }
}
