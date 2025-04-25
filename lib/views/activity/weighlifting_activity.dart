import 'package:flutter/material.dart';

class WeighliftingWidget extends StatelessWidget {
  const WeighliftingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WeightLift Activity'),
      ),
      body: Center(
        child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          'WeightLift Activity',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        ),
      ),
    ),
    );
  }
}