
import 'package:fittracker/models/activity.dart';
import 'package:fittracker/services/database.dart';
import 'package:fittracker/share/constants.dart';
import 'package:fittracker/theme/colors.dart';
import 'package:flutter/material.dart';

class RecordStats extends StatelessWidget {
  final DatabaseService _databaseService = DatabaseService();
  RecordStats({super.key});


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Activity?>>(
    future: _databaseService.getStatistics(), 
    builder: 
    (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loading();
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'An error occured ${snapshot.error.toString()}',
            ),
          );
        }

      final statistics = snapshot.data!;
      final longestTraining = statistics[0];
      final mostCaloriesBurned = statistics[1];
      final longestDistance = statistics[2];
      return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: Icon(Icons.timer),
          title: Text('Longest training'),
          subtitle: Text('${longestTraining?.durationMinutes} minutes – ${longestTraining?.activityName} – ${longestTraining?.endTime}'),
          titleTextStyle: TextStyle(color: AppColors.secondary),
        ),
        ListTile(
          leading: Icon(Icons.local_fire_department),
          title: Text('Most calories burned'),
          subtitle: Text('${mostCaloriesBurned?.caloriesBurned} – ${mostCaloriesBurned?.activityName} – ${mostCaloriesBurned?.endTime}'),
          titleTextStyle: TextStyle(color: AppColors.secondary),
        ),
        ListTile(
          leading: Icon(Icons.streetview),
          title: Text('The longest traning distance'),
          subtitle: Text('${longestDistance?.distanceKm} – ${longestDistance?.activityName} – ${longestDistance?.endTime}'),
          titleTextStyle: TextStyle(color: AppColors.secondary),
        ),
      ],
    );
  }
  );
  }
}
