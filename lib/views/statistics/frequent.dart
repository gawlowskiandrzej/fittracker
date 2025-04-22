import 'package:fittracker/services/database.dart';
import 'package:fittracker/share/constants.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class FrequentStats extends StatelessWidget {
  final DatabaseService _databaseService = DatabaseService();
  
  FrequentStats({super.key});

  @override
  Widget build(BuildContext context) {
  return FutureBuilder<Map<String, int>>(
    future: _databaseService.getActivityCounts(), // Pobierz dane z bazy
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loading();
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'An error occured ${snapshot.error.toString()}',
            ),
          );
        }

      final activityCounts = snapshot.data!;

      // Dane aktywności
      final activityNames = activityCounts.keys.toList();
      
      return SizedBox(
        height: 200,
        child: BarChart(
          BarChartData(
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, _) {
                    // Dostosowanie nazw aktywności
                    return Text(activityNames[value.toInt()]);
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true, reservedSize: 40),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            barGroups: [
              // Dostosowanie danych do barów wykresu
              for (int i = 0; i < activityNames.length; i++)
                BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: activityCounts[activityNames[i]]?.toDouble() ?? 0.0,
                      color: _getColorForActivity(i),
                    ),
                  ],
                ),
            ],
          ),
        ),
      );
    },
  );
}

// Pomocnicza funkcja do wyboru koloru dla aktywności
Color _getColorForActivity(int index) {
  switch (index) {
    case 0:
      return Colors.green; // Running
    case 1:
      return Colors.orange; // Cycling
    case 2:
      return Colors.red; // Weightlifting
    case 3:
      return Colors.blue; // Ropejumping
    default:
      return Colors.grey;
  }
}
}
