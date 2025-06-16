import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fittracker/services/database.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RunningWidget extends StatefulWidget {
  const RunningWidget({super.key});

  @override
  State<RunningWidget> createState() => _RunningWidgetState();
}

class _RunningWidgetState extends State<RunningWidget> {
  late Timer _timer;
  int _seconds = 0;
  double _km = 0.0;
  double _kalories = 0.0;
  bool _isActive = false;
  late GoogleMapController _mapController;
  StreamSubscription<Position>? _positionStream;
  final List<LatLng> _route = [];
  Set<Polyline> _polylines = {};
  final DatabaseService _databaseService = DatabaseService();
  double _previousAltitude = 0.0;
  double _currentAltitude = 0.0;
  DateTime? _lastMovementTime;
  Timer? _inactivityTimer;
  LocationAccuracy _currentAccuracy = LocationAccuracy.high;
  int _stepCount = 0;
  //StreamSubscription<double>? _barometerSubscription;

  void _restartRunning() {
    _timer.cancel();
    _positionStream?.cancel();
    setState(() {
      _isActive = false;
      _seconds = 0;
      _km = 0.0;
      _kalories = 0.0;
      _stepCount = 0;
      _currentAltitude = 0.0;
      _previousAltitude = 0.0;
      _route.clear();
    });
  }

  Future<void> _switchAccuracy(LocationAccuracy newAccuracy) async {
    if (_currentAccuracy == newAccuracy) return;

    _currentAccuracy = newAccuracy;
    await _positionStream?.cancel();
    _startLocationStream(); // restart streama z nowym accuracy
  }

  void _startLocationStream() {
    final locationSettings = LocationSettings(
      accuracy: _currentAccuracy,
      distanceFilter: 1,
    );

    _positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      _handlePositionChange(position);
    });
  }

  void _handlePositionChange(Position position) {
    LatLng newPosition = LatLng(position.latitude, position.longitude);
    double distance = 0.0;

    if (_route.isNotEmpty) {
      distance = Geolocator.distanceBetween(
        _route.last.latitude,
        _route.last.longitude,
        newPosition.latitude,
        newPosition.longitude,
      );
      if (distance >= 0.5) {
        _km += distance / 1000;

        double altitudeDiff = position.altitude - _previousAltitude;
        _previousAltitude = position.altitude;

        double altitudeFactor = 1.0;
        if (altitudeDiff > 0.5) {
          altitudeFactor = 1.1;
        } else if (altitudeDiff < -0.5) {
          altitudeFactor = 0.9;
        }

        _kalories += (distance / 1000) * 35 * altitudeFactor;

        // Szacowanie kroków (średni krok = 0.75 m)
        int steps = (distance / 0.75).round();
        _stepCount += steps;

        _lastMovementTime = DateTime.now();
        _switchAccuracy(LocationAccuracy.high); // ruch = wysoka dokładność

        _inactivityTimer?.cancel();
        _inactivityTimer = Timer(Duration(seconds: 4), () {
          _switchAccuracy(LocationAccuracy.low);
        });
      }
    } else {
      _previousAltitude = position.altitude;
      _lastMovementTime = DateTime.now();
    }

    setState(() {
      _route.add(newPosition);
      _currentAltitude = position.altitude;
      _polylines = {
        Polyline(
          polylineId: PolylineId('route'),
          points: _route,
          color: Colors.blue,
          width: 4,
        ),
      };

      // Kamera śledzi pozycję
      _mapController.animateCamera(CameraUpdate.newLatLng(newPosition));
    });
  }

  void _startRunning() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Location permission denied')));
      return;
    }

    setState(() {
      _isActive = true;
      _seconds = 0;
      _km = 0.0;
      _kalories = 0.0;
      _currentAltitude = 0.0;
      _previousAltitude = 0.0;
      _stepCount = 0;
      _route.clear();
    });

    _startLocationStream();

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  void _stopRunning() async {
    _timer.cancel();
    _positionStream?.cancel();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _isActive = false;
    });

    Map<String, dynamic> activityData = {
      'userId': user.uid,
      'startTime': Timestamp.fromDate(
        DateTime.now().subtract(Duration(seconds: _seconds)),
      ),
      'endTime': Timestamp.fromDate(DateTime.now()),
      'durationMinutes': double.parse((_seconds / 60).toStringAsFixed(2)),
      'distanceKm': double.parse(_km.toStringAsFixed(2)),
      'caloriesBurned': double.parse(_kalories.toStringAsFixed(2)),
      'reps': 0,
      'sets': 0,
      'jumps': 0,
      'steps': _stepCount,
      'type': 2,
    };

    try {
      final activityRef = await _databaseService.addActivity(activityData);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Activity saved successfully!')));

      // Po zapisaniu aktywności, zaktualizuj statystyki użytkownika
      _databaseService.updateActivityStats(
        user.uid,
        _km,
        _kalories,
        _seconds / 60,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving activity: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Running Activity')),
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
                          'Time',
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
                          'Calories',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),

                    // Dystans
                    Column(
                      children: [
                        const Icon(
                          Icons.directions_run,
                          size: 28,
                          color: Colors.green,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_km.toStringAsFixed(2)} km',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Distance',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Icon(Icons.height, size: 28, color: Colors.green),
                        const SizedBox(height: 4),
                        Text(
                          '${_currentAltitude.toStringAsFixed(0)} m',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Attitude',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Icon(
                          Icons.directions_walk,
                          size: 28,
                          color: Colors.green,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_stepCount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Steps',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),
            SizedBox(
              width: 500,
              height: 500,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(37.7749, -122.4194),
                    zoom: 14,
                  ),
                  polylines: _polylines,
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
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
                        onPressed: _isActive ? _stopRunning : _startRunning,
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
                          onPressed: _restartRunning,
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

  @override
  void dispose() {
    _timer.cancel();
    _positionStream?.cancel();
    _inactivityTimer?.cancel();
    //_barometerSubscription?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
