import 'package:fittracker/services/auth.dart';
import 'package:fittracker/share/constants.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  const SignIn({required this.toggleView});

  final Function? toggleView;

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();
  bool isLoading = false;

  String? email = "";
  String? password = "";

  @override
  Widget build(BuildContext context) {
    return isLoading ? Loading()  : Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
        actions: <Widget>[
          TextButton.icon(
            icon: const Icon(Icons.person),
            label: const Text('Register'),
            onPressed: () {
                widget.toggleView!();
            },
          ),
        ],
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
                  setState(() => isLoading = true);
                  dynamic result = await _auth.signInWithEmailAndPassword(email!, password!);
                  if (result == null) {
                    print('Error signing in');
                    setState(() => isLoading = false);
                  } else {
                    print('Signed in as ${result.uid}');
                    setState(() => isLoading = false);
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