import 'package:flutter/material.dart';

class RunningWidget extends StatelessWidget {
  const RunningWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Running Activity'),
      ),
      body: Center(
        child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          'Running Activity',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        ),
      ),
    ),
    );
  }
}