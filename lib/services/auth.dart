import 'package:firebase_auth/firebase_auth.dart';

class AuthService{
  
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // create user object based on firebase user
  // User? _userFromFirebaseUser(User? user) {
  //   return user != null ? User(uid: user.uid) : null;
  // }

  // auth change user stream
  // Stream<User?> get user {
  //   return _auth.authStateChanges()
  //       .map(_userFromFirebaseUser);
  // }

  // sign in anon
  Future signInAnon() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User? user = result.user;
      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}