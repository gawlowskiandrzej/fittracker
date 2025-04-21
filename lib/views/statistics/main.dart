import 'package:fittracker/views/statistics/frequent.dart';
import 'package:fittracker/views/statistics/general_stats.dart';
import 'package:fittracker/views/statistics/records.dart';
import 'package:flutter/material.dart';

class MainStats extends StatelessWidget {
  const MainStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('Statistics')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            StatsHeader("Main statistics"),
            const SizedBox(height: 8),
            GeneralStats(),
            const SizedBox(height: 24),

            StatsHeader('Frequent statistics'),
            const SizedBox(height: 8),
            FrequentStats(),
            const SizedBox(height: 24),

            StatsHeader('Records'),
            const SizedBox(height: 8),
            RecordStats(),
          ],
        ),
      ),
    );
  }

  Widget StatsHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
    );
  }
}
