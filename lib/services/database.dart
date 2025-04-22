import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fittracker/models/activity.dart';
import 'package:intl/intl.dart';


class DatabaseService {
  final activityCollection = FirebaseFirestore.instance.collection(
    'activities',
  );
  final activityTypesCollection = FirebaseFirestore.instance.collection(
    'activity_types',
  );

  Map<String, String> activity_types = {};
  Future getActivities() async {
    QuerySnapshot snapshot = await activityCollection.get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future addActivity(Map<String, dynamic> activity) async {
    await activityCollection.add(activity);
  }

  Future<List<Activity>> fetchRecentActivities() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    // 1. Pobierz ostatnie aktywności użytkownika
    final querySnapshot =
        await activityCollection
            .where('userId', isEqualTo: user.uid)
            .orderBy('startTime', descending: true)
            .limit(5)
            .get();

    final activities = querySnapshot.docs;

    // 2. Pobierz wszystkie typy aktywności
    final typesSnapshot = await activityTypesCollection.get();
    activity_types = {
      for (var doc in typesSnapshot.docs)
        (doc.data() as Map<String, dynamic>)['id'].toString():
            (doc.data() as Map<String, dynamic>)['type'] ?? 'Nieznany',
    };

    return activities.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final typeId = data['type'].toString(); // np. "1"
      final typeName = activity_types[typeId] ?? 'Nieznany';

      return Activity.fromFirestore(data, doc.id, typeName);
    }).toList();

  }

  Future<Map<String, int>> getActivityCounts() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return {};

  // 1. Pobierz wszystkie typy aktywności
  final typesSnapshot = await activityTypesCollection.get();
  final activityValues = {
    for (var doc in typesSnapshot.docs)
      (doc.data() as Map<String, dynamic>)['type'].toString():
          (doc.data() as Map<String, dynamic>)['id'],
  };

  // 2. Dla każdego typu aktywności pobierz liczbę wystąpień
  Map<String, int> activityCounts = {};
  for (var type in activityValues.keys) {
    final querySnapshot = await activityCollection
        .where('userId', isEqualTo: user.uid)
        .where('type', isEqualTo: activityValues[type])
        .get();

    activityCounts[type] = querySnapshot.docs.length;
  }

  return activityCounts;
}

  Future<Map<String, int>> getDailyActvityCounts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return {};

    // 1. Pobierz wszystkie typy aktywności
    Map<String, int> daywithFrequency = {};
    final typesSnapshot = await activityCollection.get();
    
    for (var doc in typesSnapshot.docs) {
      final endTime = (doc.data() as Map<String, dynamic>)['endTime'] as Timestamp;
      final dateTime = endTime.toDate();
      final weekday = DateFormat("EEEE").format(dateTime); // Get the full name of the weekday

    // Increment the count for this weekday
      if (daywithFrequency.containsKey(weekday)) {
        daywithFrequency[weekday] = daywithFrequency[weekday]! + 1;
      } else {
        daywithFrequency[weekday] = 1;
      }
    }
    return daywithFrequency;
  }
}
