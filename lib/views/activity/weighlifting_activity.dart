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
  int _sets = 0;
  int _maxsets = 3;
  int _reps = 0; // Liczba powtórzeń
  int _restTime = 30;
  bool _isBreakStarted = false;
  int _breakTimeLeft = 0;
  bool _isActive = false;
  bool _movingUp = false;
  bool _waitingForReturn = false;
  final double _liftThreshold = 5.0; // próg przyspieszenia w górę
  final double _returnThreshold = 5.0; // próg przyspieszenia w dół
  late StreamSubscription<AccelerometerEvent> _accelerometerSubscription;

  DateTime _lastRepTime = DateTime.now();
  final Duration _repCooldown = Duration(
    milliseconds: 800,
  ); // minimalny czas między powtórzeniami

  @override
  void dispose() {
    _accelerometerSubscription.cancel();
    if (_timer.isActive) {
      _timer.cancel();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  bool _checkRepCycle(AccelerometerEvent event) {
    double y = event.y;

    // Ruch w górę
    if (!_movingUp && y > _liftThreshold) {
      _movingUp = true;
      _waitingForReturn = true;
      return false;
    }

    // Powrót z ruchu w górę
    if (_movingUp && _waitingForReturn && y < -_returnThreshold) {
      _movingUp = false;
      _waitingForReturn = false;
      return true;
    }

    return false;
  }

  void _onLiftDetect() {
    setState(() {
      _reps++;
      _kalories += _calculateCalories(_reps);
    });
  }

  double _calculateCalories(int reps) {
    return reps * 0.50;
  }

  void _startLifting() async {
    setState(() {
      _isActive = true;
      _seconds = 0;
      _km = 0.0;
      _kalories = 0.0;
      _reps = 0;
      _sets = 0;
    });
    _accelerometerSubscription =
        accelerometerEvents.listen((AccelerometerEvent event) {
              if (_checkRepCycle(event)) {
                final now = DateTime.now();
                if (now.difference(_lastRepTime) > _repCooldown) {
                  _lastRepTime = now;
                  _onLiftDetect();
                }
              }
            })
            as StreamSubscription<AccelerometerEvent>;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  void _stopLifting() async {
    _timer.cancel();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return; // Jeśli użytkownik nie jest zalogowany, nie zapisuj aktywności
    }

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
      'distanceKm': 0,
      'caloriesBurned': double.parse(_kalories.toStringAsFixed(2)),
      'reps': _reps,
      'sets': _sets,
      'jumps': 0,
      'steps': 0, 
      'type': 3,
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
      appBar: AppBar(title: Text('Weightlift Activity')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
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
                          'Time',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
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
                          'Calories',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Icon(
                          Icons.repeat,
                          size: 28,
                          color: Colors.orange,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$_reps',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Reps',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Icon(
                          Icons.view_module,
                          size: 28,
                          color: Colors.green,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$_sets',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Sets',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _isActive
                ? SizedBox(
                  height: 500,
                  width: 500,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isBreakStarted
                            ? 'Pouse time: $_breakTimeLeft seconds'
                            : 'Time to exercise!',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _endSeries,
                        child: const Text('End serie'),
                      ),
                    ],
                  ),
                )
                : SizedBox(
                  height: 500,
                  width: 500,
                  child: Center(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
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
                                const Text(
                                  'Set count:',
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(
                                  width: 80,
                                  child: TextField(
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      hintText: '3',
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
                                const Text(
                                  'Break (seconds):',
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(
                                  width: 80,
                                  child: TextField(
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      hintText: '30',
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
                        onPressed: _isActive ? _stopLifting : _startLifting,
                        style: ElevatedButton.styleFrom(
                          textStyle: const TextStyle(fontSize: 18),
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(24),
                        ),
                        child: Icon(_isActive ? Icons.stop : Icons.play_arrow),
                      ),
                    ],
                  ),
                  SizedBox(height: 10, width: 10),
                  if (_isActive)
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _seconds = 0;
                              _km = 0.0;
                              _kalories = 0.0;
                              _reps = 0; // Reset liczby skoków
                              _sets = 0; // Reset liczby serii
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

  void _endSeries() {
    setState(() {
      _isBreakStarted = true;
      _breakTimeLeft = _restTime;
      _sets++;
    });

    // Uruchamiamy osobny timer tylko dla przerwy
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_breakTimeLeft > 0) {
        setState(() {
          _breakTimeLeft--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isBreakStarted = false;
          _reps = 0;
        });
        if (_sets >= _maxsets) {
          _stopLifting();
        }
      }
    });
  }
}
