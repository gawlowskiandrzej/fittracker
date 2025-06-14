import 'package:fittracker/share/constants.dart';
import 'package:flutter/material.dart';
import 'package:fittracker/models/activity.dart';
import 'package:fittracker/services/database.dart';
import 'package:fittracker/views/home/recent_activity_tile.dart';

class RecentActivitiesList extends StatelessWidget {
  final DatabaseService _databaseService = DatabaseService();

  RecentActivitiesList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Recent activities',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Activity>>(
            future: _databaseService.fetchRecentActivities(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Loading();
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('An error occurred: ${snapshot.error}'),
                );
              }

              final activities = snapshot.data ?? [];

              if (activities.isEmpty) {
                return const Center(child: Text('No recent activities'));
              }

              return ListView.builder(
                itemCount: activities.length,
                itemBuilder: (context, index) {
                  final activity = activities[index];
                  return RecentActivityTile(activity: activity);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
