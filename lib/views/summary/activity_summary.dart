import 'package:fittracker/models/activity.dart';
import 'package:flutter/material.dart';

class ActivitySummary extends StatelessWidget {
  final Activity activity;

  const ActivitySummary({
    super.key,
    required this.activity
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> statWidgets = [];

    if (activity.distanceKm != null && activity.distanceKm! > 0) {
      statWidgets.add(_buildTile('Dystans', '${activity.distanceKm!.toStringAsFixed(2)} km'));
    }
    if (activity.steps != null && activity.steps! > 0) {
      statWidgets.add(_buildTile('Kroki', '${activity.steps}'));
    }
    if (activity.caloriesBurned != null && activity.caloriesBurned! > 0) {
      statWidgets.add(_buildTile('Kalorie', '${activity.caloriesBurned!.toStringAsFixed(0)} kcal'));
    }
    if (activity.durationMinutes != null && activity.durationMinutes! > 0) {
      statWidgets.add(_buildTile('Czas trwania', '${activity.durationMinutes!.toStringAsFixed(1)} min'));
    }

    statWidgets.add(_buildTile('Data startu', activity.startTime.toString()));
    statWidgets.add(_buildTile('Data końca', activity.endTime.toString()));

    return Scaffold(
      appBar: AppBar(title: Text('Podsumowanie aktywności')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(activity.activityName!, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...statWidgets,
          ],
        ),
      ),
    );
  }

  Widget _buildTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
