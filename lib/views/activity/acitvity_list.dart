import 'package:flutter/material.dart';

class AcitvityList extends StatelessWidget {
  const AcitvityList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Chose activity',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: 10, // Replace with your activity count
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('Aktywność ${index + 1}'),
                subtitle: Text('Szczegóły aktywności ${index + 1}'),
                trailing: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () {
                    // Handle navigation to activity details
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}