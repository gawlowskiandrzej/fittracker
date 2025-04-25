import 'package:fittracker/views/activity/cycling_activity.dart';
import 'package:fittracker/views/activity/ropejumping_activity.dart';
import 'package:fittracker/views/activity/running_activity.dart';
import 'package:fittracker/views/activity/weighlifting_activity.dart';
import 'package:flutter/material.dart';

class ActivityListItem {
    final String? name;
    final String? type;
    final String? description;
    final IconData icon;


const ActivityListItem({
    required this.name,
    required this.type,
    required this.description,
    required this.icon,
  });

static const List<ActivityListItem> activityList = [
  ActivityListItem(
    name: 'Running',
    type: 'Cardio',
    description: 'A running activity to improve endurance.',
    icon: Icons.directions_run,
  ),
  ActivityListItem(
    name: 'Cycling',
    type: 'Cardio',
    description: 'A cycling activity to strengthen legs and stamina.',
    icon: Icons.pedal_bike,
  ),
  ActivityListItem(
  name: 'Rope Jumping',
  type: 'Cardio',
  description: 'An intense cardio workout that improves endurance, coordination, and overall fitness.',
  icon: Icons.sports_gymnastics,
  ),
  ActivityListItem(
    name: 'Weightlifting',
    type: 'Strength',
    description: 'A weightlifting activity to build muscle strength.',
    icon: Icons.fitness_center,
  ),
];
static const List<Widget> activityWidgets = [
  RunningWidget(),
  CyclingWidget(),
  RoperJumpingWidget(),
  WeighliftingWidget(),
];

}