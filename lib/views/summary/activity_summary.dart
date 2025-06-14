import 'package:fittracker/models/activity.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sms_advanced/sms_advanced.dart';

class ActivitySummary extends StatelessWidget {
  final Activity activity;

  const ActivitySummary({super.key, required this.activity});

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
      appBar: AppBar(title: Text('Activity summary')),
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
                  decoration: InputDecoration(
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
            Padding(padding: const EdgeInsets.symmetric(vertical: 16)),
            Center(
              child: ElevatedButton(
                child: Icon(Icons.sms),
                onPressed: () => _sendSms(phoneNumber, activity),
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

  void _sendSms(String number, Activity activity) async {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln('Podsumowanie aktywności: ${activity.activityName}');
    if (activity.distanceKm != null && activity.distanceKm! > 0) {
      buffer.writeln('Dystans: ${activity.distanceKm!.toStringAsFixed(2)} km');
    }
    if (activity.steps != null && activity.steps! > 0) {
      buffer.writeln('Kroki: ${activity.steps}');
    }
    if (activity.caloriesBurned != null && activity.caloriesBurned! > 0) {
      buffer.writeln(
        'Kalorie: ${activity.caloriesBurned!.toStringAsFixed(0)} kcal',
      );
    }
    if (activity.durationMinutes != null && activity.durationMinutes! > 0) {
      buffer.writeln(
        'Czas trwania: ${activity.durationMinutes!.toStringAsFixed(1)} min',
      );
    }
    buffer.writeln('Start: ${activity.startTime}');
    buffer.writeln('Koniec: ${activity.endTime}');

    // Upewnij się, że mamy uprawnienia
    var status = await Permission.sms.status;
    if (!status.isGranted) {
      status = await Permission.sms.request();
      if (!status.isGranted) {
        debugPrint('Brak uprawnień do wysyłania SMS.');
        return;
      }
    }

    final SmsSender sender = SmsSender();
    final SmsMessage message = SmsMessage(number, buffer.toString());

    message.onStateChanged.listen((state) {
      if (state == SmsMessageState.Sent) {
        debugPrint("SMS wysłany");
      } else if (state == SmsMessageState.Fail) {
        debugPrint("Błąd wysyłania SMS");
      }
    });

    sender.sendSms(message);
  }
}
