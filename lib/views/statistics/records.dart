import 'package:fittracker/models/activity.dart';
import 'package:fittracker/services/database.dart';
import 'package:fittracker/share/constants.dart';
import 'package:fittracker/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RecordStats extends StatelessWidget {
  final DatabaseService _databaseService = DatabaseService();
  RecordStats({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Activity?>>(
      future: _databaseService.getStatistics(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loading();
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('An error occured ${snapshot.error.toString()}'),
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
              subtitle: Text(
                '${longestTraining?.durationMinutes} minutes – ${longestTraining?.activityName} – ${DateFormat('yyyy-MM-dd HH:mm:ss').format(longestTraining?.endTime ?? DateTime.now())}',
              ),
              titleTextStyle: TextStyle(color: AppColors.secondary),
            ),
            ListTile(
              leading: Icon(Icons.local_fire_department),
              title: Text('Most calories burned'),
              subtitle: Text(
                '${mostCaloriesBurned?.caloriesBurned} kcal – ${mostCaloriesBurned?.activityName} – ${DateFormat('yyyy-MM-dd HH:mm:ss').format(mostCaloriesBurned?.endTime ?? DateTime.now())}',
              ),
              titleTextStyle: TextStyle(color: AppColors.secondary),
            ),
            ListTile(
              leading: Icon(Icons.add_road),
              title: Text('The longest traning distance'),
              subtitle: Text(
                '${longestDistance?.distanceKm} km – ${longestDistance?.activityName} – ${DateFormat('yyyy-MM-dd HH:mm:ss').format(longestDistance?.endTime ?? DateTime.now())}',
              ),
              titleTextStyle: TextStyle(color: AppColors.secondary),
            ),
          ],
        );
      },
    );
  }
}
