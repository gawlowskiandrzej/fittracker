import 'package:fittracker/models/user.dart';
import 'package:fittracker/services/auth.dart';
import 'package:fittracker/theme/theme_data.dart';
import 'package:fittracker/views/home/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<MyUser>.value(
      initialData: MyUser(uid: "-1", email: "null"),
      value: AuthService().user,
      child: MaterialApp(
        theme: appTheme,
        home: const Wrapper(),
      ),
    );
  }
}