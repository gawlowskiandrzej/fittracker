import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fittracker/models/activity.dart';

class DatabaseService{
    final activityCollection = FirebaseFirestore.instance.collection('activities');
    Future getActivities() async {
        QuerySnapshot snapshot = await activityCollection.get();
        return snapshot.docs.map((doc) => doc.data()).toList();
    }
    Future addActivity(Map<String, dynamic> activity) async {
        await activityCollection.add(activity);
    }
    List<Activity> _activityListFromSnapshot(QuerySnapshot snapshot) {
        return snapshot.docs.map((doc) {
            return Activity.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
    }
    Future<List<Activity>> fetchRecentActivities() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final querySnapshot = await FirebaseFirestore.instance
        .collection('activities')
        .where('userId', isEqualTo: user.uid)
        .orderBy('startTime', descending: true)
        .limit(5)
        .get();

    return _activityListFromSnapshot(querySnapshot);
    }
}