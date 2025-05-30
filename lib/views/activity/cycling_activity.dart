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
  List<LatLng> _route = [];
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  LatLng _simulatedPosition = LatLng(37.7749, -122.4194);

  void _startCycling() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Brak uprawnień do lokalizacji.')));
      return;
    }
    setState(() {
      _isActive = true;
      _seconds = 0;
      _km = 0.0;
      _kalories = 0.0;
      _route.clear();
      _simulatedPosition = LatLng(37.7749, -122.4194);
    });

    // _positionStream = Geolocator.getPositionStream().listen((
    //   Position position,
    // ) {
    //   final currentLatLng = LatLng(position.latitude, position.longitude);
    //   if (_route.isNotEmpty) {
    //     final distance = Geolocator.distanceBetween(
    //       _route.last.latitude,
    //       _route.last.longitude,
    //       currentLatLng.latitude,
    //       currentLatLng.longitude,
    //     ); // w metrach
    //     _km += distance / 1000.0; // konwersja na km
    //     _kalories = _km * 35; // prosta estymacja, np. 35 kcal/km
    //   }
    //   _route.add(currentLatLng);
    // });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
        //_km = _seconds / 60; // symulacja 1 km na minutę
        final newLat = _simulatedPosition.latitude + 0.0001;
        final newLng = _simulatedPosition.longitude + 0.0001;
        LatLng newPosition = LatLng(newLat, newLng);
        if (_route.isNotEmpty) {
          final distance = Geolocator.distanceBetween(
            _route.last.latitude,
            _route.last.longitude,
            newPosition.latitude,
            newPosition.longitude,
          );
          _km += distance / 1000.0;
          _kalories = _km * 35;
        }
        _route.add(newPosition);
        _simulatedPosition = newPosition;
        _mapController.animateCamera(
          CameraUpdate.newLatLng(_simulatedPosition),
        );
        _markers = {
          Marker(
            markerId: MarkerId('current'),
            position: _simulatedPosition,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueAzure,
            ),
          ),
        };
        _polylines = {
          Polyline(
            polylineId: PolylineId('route'),
            points: _route,
            color: Colors.blue,
            width: 4,
          ),
        };
      });
    });
  }

  void _stopCycling() async {
  _timer.cancel();
  _positionStream?.cancel();
  
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
    'type': 1,  // Typ aktywności - tutaj zakładamy "cycling", który ma id 1 w kolekcji activity_types
  };

  // Zapisz aktywność do Firestore
  try {
    final activityRef = await DatabaseService().addActivity(activityData);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Aktywność zapisana')));

    // Po zapisaniu aktywności, zaktualizuj statystyki użytkownika
    _updateActivityStats(user.uid, _km, _kalories, _seconds / 60);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Błąd zapisywania aktywności')));
  }
}

void _updateActivityStats(String userId, double distance, double calories, double duration) async {
  try {
    final activityStatsRef = FirebaseFirestore.instance.collection('activity_stats');

    // Pobierz obecne dane statystyk użytkownika
    final querySnapshot = await activityStatsRef.where('userId', isEqualTo: userId).get();
    if (querySnapshot.docs.isNotEmpty) {
      // Jeśli istnieje już zapis statystyk, zaktualizuj go
      final doc = querySnapshot.docs.first;
      final data = doc.data() as Map<String, dynamic>;

      // Zaktualizuj dane (sumowanie wartości)
      await doc.reference.update({
        'total_calories': data['total_calories'] + calories,
        'total_distance': data['total_distance'] + distance,
        'total_duration': data['total_duration'] + duration,
      });
    } else {
      // Jeśli nie ma jeszcze statystyk, stwórz nowy rekord
      await activityStatsRef.add({
        'userId': userId,
        'total_calories': calories,
        'total_distance': distance,
        'total_duration': duration,
      });
    }
  } catch (e) {
    print('Błąd aktualizacji statystyk: $e');
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
                          'Dystans',
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
                  markers: _markers,
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
                          onPressed: _restartCycling,
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
