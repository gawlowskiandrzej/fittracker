import 'package:cloud_firestore/cloud_firestore.dart';

class Activity {
  String? id;
  String? userId;
  int? typeId;
  double? distanceKm;
  int? steps;
  int? durationMinutes;
  DateTime? startTime;
  DateTime? endTime;
  int? caloriesBurned;
  String? activityName;



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
  });

  Activity.empty(){
    this.id = "-1";
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
      caloriesBurned: data['caloriesBurned'] ?? 0,
      durationMinutes: data['durationMinutes'] ?? 0,
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      activityName: activity,
    );
  }
}
