import 'package:fittracker/models/user.dart';
import 'package:fittracker/services/auth.dart';
import 'package:fittracker/theme/colors.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();

  String? email = "";
  String? password = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
        elevation: 0.0,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: Form(
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(hintText: 'Email'),
                onChanged: (value) {
                  setState(() => email = value);
                },
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                decoration: const InputDecoration(hintText: 'Password'),
                obscureText: true,
                onChanged: (val) {
                  setState(() => password = val);
                },
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () async {
                  print('Email: $email, Password: $password');
                  //await _auth.signInAnon();
                  dynamic result = await _auth.signInWithEmailAndPassword('email', 'password');
                  if (result == null) {
                    print('Error signing in');
                  } else {
                    print('Signed in as ${result.uid}');
                  }
                },
                child: const Text('Sign In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}