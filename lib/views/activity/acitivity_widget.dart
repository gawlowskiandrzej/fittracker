import 'package:fittracker/models/activity_list_item.dart';
import 'package:fittracker/theme/colors.dart';
import 'package:flutter/material.dart';

class ActivityWidget extends StatelessWidget {
  final ActivityListItem activity;

  const ActivityWidget({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Tu możesz dodać np. nawigację do szczegółów aktywności
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: AppColors.primary,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(activity.icon, size: 40, color: AppColors.secondary),
              const SizedBox(height: 12),
              Text(
                activity.name!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                activity.description!,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
