import 'package:fittracker/main.dart';
import 'package:fittracker/theme/colors.dart';
import 'package:flutter/material.dart';

class RecordStats extends StatelessWidget {
  const RecordStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        ListTile(
          leading: Icon(Icons.timer),
          title: Text('Longest training'),
          subtitle: Text('1h 35min – Running – 12.04.2025'),
          titleTextStyle: TextStyle(color: AppColors.secondary),
        ),
        ListTile(
          leading: Icon(Icons.local_fire_department),
          title: Text('Most calories burned'),
          subtitle: Text('870 kcal – Cycle – 07.04.2025'),
          titleTextStyle: TextStyle(color: AppColors.secondary),
        ),
        ListTile(
          leading: Icon(Icons.star),
          title: Text('The most active training'),
          subtitle: Text('15.04.2025 – 3 tranings'),
          titleTextStyle: TextStyle(color: AppColors.secondary),
        ),
      ],
    );
    ;
  }
}
