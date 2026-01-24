import 'package:flutter/material.dart';
import 'teacher/teacher_login.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      title: "Attendance App",
      debugShowCheckedModeBanner: false,
      home: TeacherLogin(),
      theme: ThemeData(
          fontFamily: GoogleFonts.lato().fontFamily,
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.teal,
            primary: Colors.blue,
            secondary: Colors.green,
            error: Colors.red,
        ),
        appBarTheme: AppBarTheme(
          titleTextStyle: TextStyle(
            fontSize: 20,
            color: Colors.black
          ),
        ),
        textTheme: TextTheme(
          titleSmall: TextStyle(
            fontWeight: FontWeight.bold,
              fontSize: 16
          ),
          titleMedium: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20
          ),
          titleLarge: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 35
          )
        ),
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16
          ),
        ),
        useMaterial3: true
      ),
    );
  }
}
