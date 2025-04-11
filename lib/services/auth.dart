import 'package:firebase_auth/firebase_auth.dart';
import 'package:fittracker/models/user.dart';

class AuthService{
  
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<MyUser> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  MyUser _userFromFirebaseUser(User? user) {
    return user != null ? MyUser(uid: user.uid) : MyUser(uid: "-1");
  }

  // sign in anon
  Future signInAnon() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User? user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}