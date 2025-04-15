import 'package:fittracker/models/user.dart';
import 'package:fittracker/views/home/home.dart';
import 'package:fittracker/views/login/login_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<MyUser?>(context);
    if (user == null || user.uid == "-1") {
      return Login();
    } else {
      return Home();
    }
  }
}