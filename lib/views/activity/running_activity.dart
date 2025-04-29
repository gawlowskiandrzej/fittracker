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
        child: Center(
          child: Column(
          children: [
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () => {}, child: Text("Start running")),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () => {}, child: Text("Stop running"))
          ],
        )
        )
    ),
    );
  }
}