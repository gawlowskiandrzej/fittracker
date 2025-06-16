import 'package:fittracker/models/activity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:telephony/telephony.dart';

class ActivitySummary extends StatefulWidget {
  final Activity activity;

  ActivitySummary({super.key, required this.activity});

  @override
  State<ActivitySummary> createState() => _ActivitySummaryState();
}

class _ActivitySummaryState extends State<ActivitySummary> {
  final telephony = Telephony.instance;

  @override
  Widget build(BuildContext context) {
    final List<Widget> statWidgets = [];
    String phoneNumber = '';

    if (widget.activity.distanceKm != null && widget.activity.distanceKm! > 0) {
      statWidgets.add(
        _buildTile(
          'Distance',
          '${widget.activity.distanceKm!.toStringAsFixed(2)} km',
        ),
      );
    }
    if (widget.activity.steps != null && widget.activity.steps! > 0) {
      statWidgets.add(_buildTile('Steps', '${widget.activity.steps}'));
    }
    if (widget.activity.caloriesBurned != null &&
        widget.activity.caloriesBurned! > 0) {
      statWidgets.add(
        _buildTile(
          'Calories',
          '${widget.activity.caloriesBurned!.toStringAsFixed(0)} kcal',
        ),
      );
    }
    if (widget.activity.durationMinutes != null &&
        widget.activity.durationMinutes! > 0) {
      statWidgets.add(
        _buildTile(
          'Duration',
          '${widget.activity.durationMinutes!.toStringAsFixed(1)} min',
        ),
      );
    }

    if (widget.activity.steps != null && widget.activity.steps! > 0) {
      statWidgets.add(_buildTile('Steps', '${widget.activity.steps}'));
    }

    if (widget.activity.jumps != null && widget.activity.jumps! > 0) {
      statWidgets.add(
        _buildTile('Rope jumps', '${widget.activity.jumps!.toInt()}'),
      );
    }

    if (widget.activity.reps != null && widget.activity.reps! > 0) {
      statWidgets.add(
        _buildTile('Weightlift reps', '${widget.activity.reps!.toInt()}'),
      );
    }

    if (widget.activity.sets != null && widget.activity.sets! > 0) {
      statWidgets.add(
        _buildTile('Weightlift sets', '${widget.activity.sets!.toInt()}'),
      );
    }

    statWidgets.add(
      _buildTile(
        'Start date',
        DateFormat('yyyy-MM-dd HH:mm:ss').format(widget.activity.startTime!),
      ),
    );
    statWidgets.add(
      _buildTile(
        'End date',
        DateFormat('yyyy-MM-dd HH:mm:ss').format(widget.activity.endTime!),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Activity summary')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.activity.activityName!,
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
                onPressed: () => sendDirectSms(phoneNumber, widget.activity),
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

  Future<void> sendDirectSms(String number, Activity activity) async {
    String message = "";
    message += 'Summary of activity: ${activity.activityName}\n';
    if (activity.distanceKm != null && activity.distanceKm! > 0) {
      message += 'Distance: ${activity.distanceKm!.toStringAsFixed(2)} km\n';
    }
    if (activity.steps != null && activity.steps! > 0) {
      message += 'Steps: ${activity.steps}\n';
    }
    if (activity.jumps != null && activity.jumps! > 0) {
      message += 'Rope jumps: ${activity.jumps!.toInt()}\n';
    }
    if (activity.reps != null && activity.reps! > 0) {
      message += 'Weightlift reps: ${activity.reps!.toInt()}\n';
    }
    if (activity.sets != null && activity.sets! > 0) {
      message += 'Weightlift sets: ${activity.sets!.toInt()}\n';
    }
    if (activity.caloriesBurned != null && activity.caloriesBurned! > 0) {
      message +=
          'Calories: ${activity.caloriesBurned!.toStringAsFixed(0)} kcal\n';
    }

    // Załóżmy, że endTime i startTime to DateTime, więc wyliczamy Duration
    //final duration = activity.endTime!.difference(activity.startTime!);
    message += 'Overall activity time: ${activity.durationMinutes} min';
    print(message);

    await _sendSms(number, message);
  }

  Future<void> _sendSms(String number, String message) async {
    try {
      var status = await Permission.sms.status;
      if (!status.isGranted) {
        status = await Permission.sms.request();
        if (!status.isGranted) {
          print("Nie masz odpowiednich uprawnień");
          return;
        }
      }

      final bool? permissionsGranted = await telephony.requestSmsPermissions;
      if (permissionsGranted != true) {
        print("Uprawnienia odrzucone");
        return;
      }

      await telephony.sendSms(to: number, message: message);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Podsumowanie wysłane pomyślnie!')),
      );
      print("SMS wysłany do $number");
    } catch (e, stacktrace) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Nie można wysłać podsumowania!')));
      print("Błąd podczas wysyłania SMS: $e");
      print("Stacktrace: $stacktrace");
    }
  }
}
