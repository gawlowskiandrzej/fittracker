import 'package:flutter/material.dart';
import 'package:fittracker/models/activity.dart';
import 'package:fittracker/services/database.dart';
import 'package:fittracker/views/home/recent_activity_tile.dart';

class RecentActivitiesList extends StatelessWidget {
  final DatabaseService _databaseService = DatabaseService();

  RecentActivitiesList({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Activity>>(
      future: _databaseService.fetchRecentActivities(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Wystąpił błąd podczas ładowania aktywności. ${snapshot.error.toString()}',
            ),
          );
        }

        final activities = snapshot.data ?? [];

        if (activities.isEmpty) {
          return const Center(child: Text('Brak ostatnich aktywności.'));
        }

        return ListView.builder(
          itemCount: activities.length,
          itemBuilder: (context, index) {
            final activity = activities[index];
            return RecentActivityTile(activity: activity);
          },
        );
      },
    );
  }
}
