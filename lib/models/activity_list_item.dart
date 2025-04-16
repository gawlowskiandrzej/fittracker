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
    name: 'Yoga',
    type: 'Flexibility',
    description: 'A yoga session to improve flexibility and mindfulness.',
    icon: Icons.self_improvement,
  ),
  ActivityListItem(
    name: 'Weightlifting',
    type: 'Strength',
    description: 'A weightlifting activity to build muscle strength.',
    icon: Icons.fitness_center,
  ),
];
}