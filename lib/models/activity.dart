import 'package:cloud_firestore/cloud_firestore.dart';

class Activity {
  String? id;
  String? userId;
  int? typeId;
  double? distanceKm;
  int? steps;
  double? durationMinutes;
  DateTime? startTime;
  DateTime? endTime;
  double? caloriesBurned;
  String? activityName;
  int? jumps;
  int? reps;
  int? sets;

  Activity({
    required this.id,
    required this.typeId,
    required this.distanceKm,
    required this.steps,
    required this.durationMinutes,
    required this.startTime,
    required this.endTime,
    required this.userId,
    required this.caloriesBurned,
    required this.activityName,
    required this.jumps,
    required this.reps,
    required this.sets,
  });

  Activity.empty() {
    id = "-1";
  }

  factory Activity.fromFirestore(
    Map<String, dynamic> data,
    String id,
    String activity,
  ) {
    return Activity(
      id: id,
      userId: data['userId'] ?? '-1',
      typeId: data['type'] ?? 'unknown',
      distanceKm: (data['distanceKm'] ?? 0).toDouble(),
      steps: data['steps'] ?? 0,
      caloriesBurned: data['caloriesBurned'].toDouble() ?? 0,
      durationMinutes: data['durationMinutes'].toDouble() ?? 0,
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      jumps: data['jumps'] ?? 0,
      reps: data['reps'] ?? 0,
      sets: data['sets'] ?? 0,
      activityName: activity,
    );
  }
}
