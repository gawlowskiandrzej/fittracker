import 'package:fittracker/models/activity.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:telephony/telephony.dart';

class ActivitySummary extends StatelessWidget {
  final Activity activity;
  final telephony = Telephony.instance;

  ActivitySummary({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    final List<Widget> statWidgets = [];
    String phoneNumber = '';

    if (activity.distanceKm != null && activity.distanceKm! > 0) {
      statWidgets.add(
        _buildTile('Distance', '${activity.distanceKm!.toStringAsFixed(2)} km'),
      );
    }
    if (activity.steps != null && activity.steps! > 0) {
      statWidgets.add(_buildTile('Steps', '${activity.steps}'));
    }
    if (activity.caloriesBurned != null && activity.caloriesBurned! > 0) {
      statWidgets.add(
        _buildTile(
          'Calories',
          '${activity.caloriesBurned!.toStringAsFixed(0)} kcal',
        ),
      );
    }
    if (activity.durationMinutes != null && activity.durationMinutes! > 0) {
      statWidgets.add(
        _buildTile(
          'Duration',
          '${activity.durationMinutes!.toStringAsFixed(1)} min',
        ),
      );
    }

    statWidgets.add(_buildTile('Start date', activity.startTime.toString()));
    statWidgets.add(_buildTile('End date', activity.endTime.toString()));

    return Scaffold(
      appBar: AppBar(title: const Text('Activity summary')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              activity.activityName!,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...statWidgets,
            const SizedBox(height: 24),
            Center(
              child: SizedBox(
                width: 200,
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Phone number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  onChanged: (value) {
                    phoneNumber = value.trim();
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                child: const Icon(Icons.sms),
                onPressed: () => sendDirectSms(phoneNumber, "activity"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<void> sendDirectSms(String number, String message) async {
    try {
      var status = await Permission.sms.status;
      if (!status.isGranted) {
        status = await Permission.sms.request();
        if (!status.isGranted) {
          print("Brak uprawnień do SMS");
          return;
        }
      }

      final bool? permissionsGranted = await telephony.requestSmsPermissions;
      if (permissionsGranted != true) {
        print("Uprawnienia odrzucone");
        return;
      }

      await telephony.sendSms(to: number, message: message);
      print("SMS wysłany do $number: $message");
    } catch (e, stacktrace) {
      print("Błąd podczas wysyłania SMS: $e");
      print("Stacktrace: $stacktrace");
    }
  }
}
