import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fittracker/models/activity.dart';

class DatabaseService {
  final activityCollection = FirebaseFirestore.instance.collection(
    'activities',
  );
  final activityTypesCollection = FirebaseFirestore.instance.collection(
    'activity_types',
  );

  List<String> activity_types = [];
  Future getActivities() async {
    QuerySnapshot snapshot = await activityCollection.get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future addActivity(Map<String, dynamic> activity) async {
    await activityCollection.add(activity);
  }

  List<Activity> _activityListFromSnapshot(QuerySnapshot snapshot) {
    activity_types =
        activityTypesCollection.get().then((value) {
              return value.docs.map((doc) => doc.data()).toList()
                  as List<String>;
            })
            as List<String>;
    return snapshot.docs.map((doc) {
      return Activity.fromFirestore(
        doc.data() as Map<String, dynamic>,
        doc.id,
        "",
      );
    }).toList();
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
    final Map<String, String> typeIdToName = {
      for (var doc in typesSnapshot.docs)
        doc.id: (doc.data() as Map<String, dynamic>)['id'] ?? 'Nieznany',
    };

    // 3. Zmapuj dokumenty na obiekty Activity z nazwą aktywności
    return activities.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final typeId = data['type'];
      final typeName = typeIdToName[typeId] ?? 'Nieznany';

      return Activity.fromFirestore(data, doc.id, typeName);
    }).toList();
  }
}
