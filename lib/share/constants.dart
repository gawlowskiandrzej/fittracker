import 'package:fittracker/theme/colors.dart';
import 'package:flutter/material.dart';

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(); // pętla nieskończona
  }

  @override
  void dispose() {
    _controller.dispose(); // zawsze czyścimy
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 0, 0, 0),
      body: Center(
        child: RotationTransition(
          turns: _controller,
          child: Container(
            width: 60,
            height: 60,
            child: const Icon(
              Icons.sync,
              size: 50,
              color: AppColors.secondary,
            ),
          ),
        ),
      ),
    );
  }
}