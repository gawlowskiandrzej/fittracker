import 'package:fittracker/services/database.dart';
import 'package:fittracker/share/constants.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GeneralStats extends StatelessWidget {
  const GeneralStats({super.key});

  @override
  Widget build(BuildContext context) {
    // Lista dni tygodnia
    DatabaseService databaseService = DatabaseService();
    const List<String> weekDays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    var i = 0;

    return FutureBuilder<Map<String, int>>(
      future: databaseService.getDailyActvityCounts(), // Pobierz dane z bazy
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loading();
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('An error occured ${snapshot.error.toString()}'),
          );
        }

        final activityFrequency = snapshot.data!;

        return Column(
          children: [
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 5,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          // Zaokrąglamy wartość do najbliższej liczby całkowitej
                          int roundedValue = value.toInt();
                          // Jeśli chcesz pokazać tylko wartości całkowite
                          return Text('$roundedValue');
                        },
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          // Zwracamy odpowiedni dzień tygodnia na podstawie indeksu
                          int index = value.toInt();
                          i++;
                          if (index >= 0 &&
                              index < weekDays.length &&
                              i % 2 == 1) {
                            return Text(weekDays[index]);
                          } else {
                            return const Text('');
                          }
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        for (int i = 0; i < weekDays.length; i++)
                          FlSpot(
                            i.toDouble(),
                            activityFrequency[weekDays[i]]?.toDouble() ?? 0.0,
                          ),
                      ],
                      isCurved: true,
                      barWidth: 3,
                      color: Colors.blue,
                      dotData: FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
