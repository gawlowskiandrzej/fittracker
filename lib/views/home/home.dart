import 'package:fittracker/models/activity.dart';
import 'package:fittracker/services/auth.dart';
import 'package:fittracker/services/database.dart';
import 'package:fittracker/views/home/recent_activity_tile.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  Home({super.key});

  final AuthService _auth = AuthService();
  final DatabaseService _databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FitTracker'),
        elevation: 0.0,
        actions: <Widget>[
          TextButton.icon(
            icon: const Icon(Icons.person),
            label: const Text('Logout'),
            onPressed: () async {
              await _auth.signOut();
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Activity>>(
        future: _databaseService.fetchRecentActivities(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Wystąpił błąd podczas ładowania aktywności. ${snapshot.error.toString()}'));
          }

          final activities = snapshot.data ?? [];

          if (activities.isEmpty) {
            return const Center(child: Text('Brak ostatnich aktywności.'));
          }

          return ListView.builder(
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activity = activities[index];
              return RecentActivityTile(
                activity: activity,
              );
            },
          );
        },
      ),
    );
  }
}