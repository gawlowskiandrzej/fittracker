import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fittracker/services/database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CyclingWidget extends StatefulWidget {
  const CyclingWidget({super.key});

  @override
  _CyclingWidgetState createState() => _CyclingWidgetState();
}

class _CyclingWidgetState extends State<CyclingWidget> {
  late Timer _timer;
  int _seconds = 0;
  double _km = 0.0;
  double _kalories = 0.0;
  bool _isActive = false;
  late GoogleMapController _mapController;
  StreamSubscription<Position>? _positionStream;
  final List<LatLng> _route = [];
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  DateTime? _lastMovementTime;
  Timer? _inactivityTimer;
  LocationAccuracy _currentAccuracy =
      LocationAccuracy.high; // domyślna dokładność
  final DatabaseService _databaseService = DatabaseService();

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
        _kalories += (distance / 100) * 35;

        _lastMovementTime = DateTime.now();
        _switchAccuracy(LocationAccuracy.high); // ruch = wysoka dokładność

        _inactivityTimer?.cancel();
        _inactivityTimer = Timer(Duration(seconds: 4), () {
          _switchAccuracy(LocationAccuracy.low);
        });
      }
    } else {
      _lastMovementTime = DateTime.now();
    }

    setState(() {
      _route.add(newPosition);
      _polylines = {
        Polyline(
          polylineId: PolylineId('route'),
          points: _route,
          color: Colors.blue,
          width: 4,
        ),
      };
      _mapController.animateCamera(CameraUpdate.newLatLng(newPosition));
    });
  }

  void _startCycling() async {
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
      _route.clear();
    });

    _startLocationStream();

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  void _stopCycling() async {
    _timer.cancel();
    _positionStream?.cancel();
    _positionStream = null;

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
      'jumps':0,
      'steps': 0,
      'type': 1,
    };

    try {
      final activityRef = await _databaseService.addActivity(activityData);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Activity saved successfully!')));

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

  void _restartCycling() {
    _timer.cancel();
    _positionStream?.cancel();
    setState(() {
      _isActive = false;
      _seconds = 0;
      _km = 0.0;
      _kalories = 0.0;
      _route.clear();
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    if (_isActive) {
      _timer.cancel();
    }
    _positionStream?.cancel();
    _positionStream = null;
    _inactivityTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cycling Activity')),
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
                          Icons.directions_bike,
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
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),
            // Mapa na środku ekranu
            SizedBox(
              width: 500, // szerokość mapy
              height: 500, // wysokość mapy
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
                        onPressed: _isActive ? _stopCycling : _startCycling,
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
                          onPressed: _restartCycling,
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
