import 'package:flutter/material.dart';

class RoperJumpingWidget extends StatelessWidget {
  const RoperJumpingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rope Jumping Activity'),
      ),
      body: Center(
        child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          'Rope Jumping Activity',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        ),
      ),
    ),
    );
  }
}