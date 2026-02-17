import 'package:flutter/material.dart';

void main() {
  runApp(const PlaceholderApp());
}

class PlaceholderApp extends StatelessWidget {
  const PlaceholderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            "Run main_teacher.dart or main_student.dart",
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
