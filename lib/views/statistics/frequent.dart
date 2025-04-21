import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class FrequentStats extends StatelessWidget {
  const FrequentStats({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  const activityNames = ['Running', 'Cycle', 'Weightlifting'];
                  return Text(activityNames[value.toInt()]);
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [BarChartRodData(toY: 18, color: Colors.green)],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [BarChartRodData(toY: 12, color: Colors.orange)],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [BarChartRodData(toY: 9, color: Colors.red)],
            ),
          ],
        ),
      ),
    );
    ;
  }
}
