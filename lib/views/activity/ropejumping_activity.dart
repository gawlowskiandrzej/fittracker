import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fittracker/services/database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sensors_plus/sensors_plus.dart';

class RoperJumpingWidget extends StatefulWidget {
  const RoperJumpingWidget({super.key});

  @override
  _RoperJumpingWidgetState createState() => _RoperJumpingWidgetState();
}

class _RoperJumpingWidgetState extends State<RoperJumpingWidget> {
  late Timer _timer;
  int _seconds = 0;
  double _km = 0.0;
  double _kalories = 0.0;
  int _jumps = 0;
  bool _isActive = false;
  late double _previousAccelerationY;

  @override
  void initState() {
    super.initState();

    // Inicjalizacja poprzedniej wartości dla detekcji skoków
    _previousAccelerationY = 0.0;

    // Nasłuchiwanie danych z akcelerometru
    accelerometerEvents.listen((AccelerometerEvent event) {
      // Zmienna "event" zawiera dane z akcelerometru (x, y, z)
      // Skoki mogą być wykrywane na podstawie zmiany w osi Y (czyli przyspieszenie w pionie)
      if (_isJumping(event)) {
        _onJumpDetected();
      }
    });
  }

  bool _isJumping(AccelerometerEvent event) {
    // Prosty algorytm do wykrywania skoku
    // Sprawdzamy, czy zmiana w osi Y jest wystarczająco duża, aby uznać to za skok
    double accelerationThreshold =
        12.0; // Próg przyspieszenia dla wykrywania skoku
    double currentAccelerationY = event.y;

    // Jeśli zmiana w osi Y jest wystarczająca, uznajemy to za skok
    if ((currentAccelerationY - _previousAccelerationY).abs() >
        accelerationThreshold) {
      _previousAccelerationY = currentAccelerationY;
      return true;
    }

    return false;
  }

  void _onJumpDetected() {
    setState(() {
      _jumps++;
      _kalories = _calculateCalories(_jumps);
    });
  }

  double _calculateCalories(int jumps) {
    return jumps * 0.05;
  }

  double _simulateAcceleration() {
    // Symulujemy zmianę przyspieszenia (oscy Y) - losowo w zakresie -15 do 15
    return (Random().nextDouble() - 0.5) * 30.0;
  }

  void _startJumping() async {
    setState(() {
      _isActive = true;
      _seconds = 0;
      _km = 0.0;
      _kalories = 0.0;
      _jumps = 0; // Reset liczby skoków
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;

        // Symulacja zmiany pozycji GPS (jeśli chcesz także dodać symulację ruchu po mapie)
        double newLat =
            37.7749 +
            (Random().nextDouble() - 0.5) *
                0.0001; // losowa zmiana szerokości geograficznej
        double newLng =
            -122.4194 +
            (Random().nextDouble() - 0.5) *
                0.0001; // losowa zmiana długości geograficznej

        LatLng newPosition = LatLng(newLat, newLng);

        // Symulacja zmiany danych akcelerometru (np. osi Y)
        // Generujemy losowe przyspieszenie, które będzie symulować skok
        double accelerationY = _simulateAcceleration();

        // Sprawdzamy, czy nastąpił "skok" na podstawie zmiany w przyspieszeniu (na osi Y)
        if (_isJumping(
          AccelerometerEvent(0.0, accelerationY, 0.0, DateTime.now()),
        )) {
          _onJumpDetected();
        }
      });
    });
  }

  void _stopJumping() async {
    _timer.cancel();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null)
      return; // Jeśli użytkownik nie jest zalogowany, nie zapisuj aktywności

    setState(() {
      _isActive = false;
    });

    // Tworzenie mapy danych aktywności
    Map<String, dynamic> activityData = {
      'userId': user.uid,
      'startTime': Timestamp.fromDate(
        DateTime.now().subtract(Duration(seconds: _seconds)),
      ),
      'endTime': Timestamp.fromDate(DateTime.now()),
      'durationMinutes': double.parse((_seconds / 60).toStringAsFixed(2)),
      'distanceKm': double.parse(_km.toStringAsFixed(2)),
      'caloriesBurned': double.parse(_kalories.toStringAsFixed(2)),
      'steps':
          0, // Jeśli nie monitorujesz kroków, to będzie 0, możesz to zaktualizować
      'type':
          4, // Typ aktywności - tutaj zakładamy "cycling", który ma id 1 w kolekcji activity_types
    };
    // Zapisz aktywność do Firestore
    try {
      final activityRef = await DatabaseService().addActivity(activityData);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Activity saved successfully!')));

      // Po zapisaniu aktywności, zaktualizuj statystyki użytkownika
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving activity: $e')));
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Rope Jumping Activity')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Karta z czasem i dystansem
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        const Icon(Icons.timer, size: 28, color: Colors.blue),
                        const SizedBox(height: 4),
                        Text(
                          _formatTime(_seconds),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Czas',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),

                    // Kalorie
                    Column(
                      children: [
                        const Icon(
                          Icons.local_fire_department,
                          size: 28,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_kalories.toStringAsFixed(0)} kcal',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Kalorie',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),
            // Mapa na środku ekranu
            SizedBox(
              width: 500,
              height: 500,
              child: Center(
                child: Container(
                  width: 150, // Szerokość liczników
                  height: 150, // Wysokość liczników
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$_jumps',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
            // Przycisk Start/Stop na dole, wycentrowany
            Card(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: _isActive ? _stopJumping : _startJumping,
                        style: ElevatedButton.styleFrom(
                          textStyle: const TextStyle(fontSize: 18),
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(24),
                        ),
                        child: Icon(_isActive ? Icons.stop : Icons.play_arrow),
                      ),
                    ],
                  ),
                  if (_isActive)
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _seconds = 0;
                              _km = 0.0;
                              _kalories = 0.0;
                              _jumps = 0; // Reset liczby skoków
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            textStyle: const TextStyle(fontSize: 18),
                            shape: CircleBorder(),
                            padding: EdgeInsets.all(24),
                          ),
                          child: Icon(Icons.replay),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
