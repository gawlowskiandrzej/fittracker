import 'package:fittracker/services/auth.dart';
import 'package:fittracker/share/constants.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  const Register({super.key, required this.toggleView});

  final Function? toggleView;

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String? email = "";
  String? password = "";

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Loading()
        : Scaffold(
          appBar: AppBar(
            title: const Text('Register'),
            actions: <Widget>[
              TextButton.icon(
                icon: const Icon(Icons.person),
                label: const Text('Sign In'),
                onPressed: () {
                  widget.toggleView!();
                },
              ),
            ],
            elevation: 0.0,
          ),
          body: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 20.0,
              horizontal: 50.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    decoration: const InputDecoration(hintText: 'Email'),
                    validator:
                        (value) => value!.isEmpty ? 'Enter an email' : null,
                    onChanged: (value) {
                      setState(() => email = value);
                    },
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    validator:
                        (value) => value!.isEmpty ? 'Enter a password' : null,
                    decoration: const InputDecoration(hintText: 'Password'),
                    obscureText: true,
                    onChanged: (val) {
                      setState(() => password = val);
                    },
                  ),
                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        print('Email: $email, Password: $password');
                        //await _auth.signInAnon();
                        setState(() => isLoading = true);
                        dynamic result = await _auth
                            .registerWithEmailAndPassword(email!, password!);
                        if (result == null) {
                          print('Error signing in');
                          setState(() => isLoading = false);
                        } else {
                          print('Signed in as ${result.uid}');
                          setState(() => isLoading = false);
                        }
                      }
                    },
                    child: const Text('Register'),
                  ),
                ],
              ),
            ),
          ),
        );
  }
}
