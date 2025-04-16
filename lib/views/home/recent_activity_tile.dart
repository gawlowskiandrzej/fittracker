import 'package:fittracker/models/activity.dart';
import 'package:fittracker/theme/colors.dart';
import 'package:flutter/material.dart';

class RecentActivityTile extends StatelessWidget {
  const RecentActivityTile({super.key, required this.activity});

  final Activity? activity;

  @override
  Widget build(BuildContext context) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
    padding: const EdgeInsets.all(16.0),
    decoration: BoxDecoration(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(8.0),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  activity?.type ?? 'Unknown Activity',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8.0),
                const Icon(Icons.access_time, size: 16.0, color: Colors.white70),
                const SizedBox(width: 4.0),
                Text(
                  '${activity?.durationMinutes ?? '0'} min',
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            const Text('You completed a workout!'),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: () {
            // Handle navigation to activity details
          },
        ),
      ],
    ),
  );
}
}