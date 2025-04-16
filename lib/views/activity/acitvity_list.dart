import 'package:fittracker/models/activity_list_item.dart';
import 'package:fittracker/views/activity/acitivity_widget.dart';
import 'package:flutter/material.dart';

class AcitvityList extends StatelessWidget {
  const AcitvityList({super.key});

  @override
Widget build(BuildContext context) {
  final activities = ActivityListItem.activityList;

  return Scaffold(
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.all(12.0),
          child: Text(
            "Choose activity",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: GridView.builder(
              itemCount: activities.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              itemBuilder: (context, index) {
                return ActivityWidget(activity: activities[index]);
              },
            ),
          ),
        ),
      ],
    ),
  );
}
}