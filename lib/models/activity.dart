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
  double? jumps;
  double? reps;
  double? sets;

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
      jumps: data['jumps'].toDouble() ?? 0,
      reps: data['reps'].toDouble() ?? 0,
      sets: data['sets'].toDouble() ?? 0,
      activityName: activity,
    );
  }
}
