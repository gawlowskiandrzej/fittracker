import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fittracker/services/database.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class WeighliftingWidget extends StatefulWidget {
  const WeighliftingWidget({super.key});

  @override
  State<WeighliftingWidget> createState() => _WeighliftingWidgetState();
}

class _WeighliftingWidgetState extends State<WeighliftingWidget> {
  late Timer _timer;
  int _seconds = 0;
  double _km = 0.0;
  double _kalories = 0.0;
  int _jumps = 0;
  int _sets = 0;
  int _maxsets = 3;
  int _reps = 0; // Liczba powtórzeń
  int _restTime = 30;
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
      if (_isLifting(event)) {
        _onLiftDetect();
      }
    });
  }

void _onLiftDetect() {
    setState(() {
      _jumps++;
      _kalories = _calculateCalories(_jumps);
    });
  }

   double _calculateCalories(int jumps) {
    // Prosty wzór do obliczenia kalorii na podstawie liczby skoków
    // Zakładając, że średnio jeden skok spala 0.05 kalorii
    return jumps * 0.05;
  }

  bool _isLifting(AccelerometerEvent event) {
    // Prosty algorytm do wykrywania skoku
    // Sprawdzamy, czy zmiana w osi Y jest wystarczająco duża, aby uznać to za skok
    double accelerationThreshold = 12.0; // Próg przyspieszenia dla wykrywania skoku
    double currentAccelerationY = event.y;

    // Jeśli zmiana w osi Y jest wystarczająca, uznajemy to za skok
    if ((currentAccelerationY - _previousAccelerationY).abs() > accelerationThreshold) {
      _previousAccelerationY = currentAccelerationY;
      return true;
    }
    
    return false;
  }
  
void _startJumping() async {
    setState(() {
      _isActive = true;
      _seconds = 0;
      _km = 0.0;
      _kalories = 0.0;
      _reps = 0; 
      
      _sets = 0; 
    });

     _timer = Timer.periodic(Duration(seconds: 1), (timer) {
    setState(() {
      _seconds++;

      // Symulacja zmiany danych akcelerometru (np. osi Y)
      // Generujemy losowe przyspieszenie, które będzie symulować skok
      double accelerationY = _simulateAcceleration();

      // Sprawdzamy, czy nastąpił "skok" na podstawie zmiany w przyspieszeniu (na osi Y)
      if (_isLifting(AccelerometerEvent(0.0, accelerationY, 0.0, DateTime.now()))) {
        _onLiftDetect();
      }
    });
  });
  }

  double _simulateAcceleration() {
  // Symulujemy zmianę przyspieszenia (oscy Y) - losowo w zakresie -15 do 15
  return (Random().nextDouble() - 0.5) * 30.0;
}
     void _stopJumping() async {
  _timer.cancel();
  
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;  // Jeśli użytkownik nie jest zalogowany, nie zapisuj aktywności
  
  setState(() {
    _isActive = false;
  });

  // Tworzenie mapy danych aktywności
  Map<String, dynamic> activityData = {
    'userId': user.uid,
    'startTime': Timestamp.fromDate(DateTime.now().subtract(Duration(seconds: _seconds))),
    'endTime': Timestamp.fromDate(DateTime.now()),
    'durationMinutes': double.parse((_seconds / 60).toStringAsFixed(2)),
    'distanceKm': double.parse(_km.toStringAsFixed(2)),
    'caloriesBurned': double.parse(_kalories.toStringAsFixed(2)),
    'steps': 0, // Jeśli nie monitorujesz kroków, to będzie 0, możesz to zaktualizować
    'type': 4,  // Typ aktywności - tutaj zakładamy "cycling", który ma id 1 w kolekcji activity_types
  };
  // Zapisz aktywność do Firestore
  try {
    final activityRef = await DatabaseService().addActivity(activityData);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Aktywność zapisana')));

    // Po zapisaniu aktywności, zaktualizuj statystyki użytkownika
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Błąd zapisywania aktywności')));
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
      appBar: AppBar(
        title: Text('Weightlift Activity'),
      ),
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
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const Text('Time', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    Column(
                      children: [
                        const Icon(Icons.local_fire_department, size: 28, color: Colors.red),
                        const SizedBox(height: 4),
                        Text(
                          '${_kalories.toStringAsFixed(0)} kcal',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const Text('Calories', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    Column(
                      children: [
                        const Icon(Icons.repeat, size: 28, color: Colors.orange),
                        const SizedBox(height: 4),
                        Text(
                          '$_reps',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const Text('Reps', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    Column(
                      children: [
                        const Icon(Icons.view_module, size: 28, color: Colors.green),
                        const SizedBox(height: 4),
                        Text(
                          '$_sets',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const Text('Sets', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),

                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),
            SizedBox(
            height: 500,
            width: 500,
            child: Center(
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 16),

                      // Wybór liczby serii
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Liczba serii:', style: TextStyle(fontSize: 16)),
                          SizedBox(
                            width: 80,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: 'np. 3',
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _maxsets = int.tryParse(value) ?? 3;
                                });
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Długość przerwy
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Przerwa (sekundy):', style: TextStyle(fontSize: 16)),
                          SizedBox(
                            width: 80,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: 'np. 30',
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _restTime = int.tryParse(value) ?? 30;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

            // Mapa na środku ekranu
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
                        child: Icon(_isActive ? Icons.stop : Icons.play_arrow),
                        style: ElevatedButton.styleFrom(
                          textStyle: const TextStyle(fontSize: 18),
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(24),
                        ),
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
                          child: Icon(Icons.replay),
                          style: ElevatedButton.styleFrom(
                            textStyle: const TextStyle(fontSize: 18),
                            shape: CircleBorder(),
                            padding: EdgeInsets.all(24),
                          ),
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