import 'package:flutter/material.dart';

class TeacherLogin extends StatelessWidget {
  const TeacherLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Teacher Login")),
      body: const Center(
        child: Text("Teacher Login Screen"),
      ),
    );
  }
}
