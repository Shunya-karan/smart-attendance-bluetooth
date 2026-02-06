import 'package:flutter/material.dart';
import 'package:smart_attendance_bluetooth/student/student_home.dart';
import 'package:smart_attendance_bluetooth/student/student_info.dart';
import 'package:smart_attendance_bluetooth/student/student_main.dart';
import 'teacher/teacher_login.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

Future<bool> hasStudentInfo() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString("name") != null &&
      prefs.getString("seatNumber") != null;
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      title: "Attendance App",
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<bool>(
        future: hasStudentInfo(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.data == true) {
            return  StudentMain();
          } else {
            return const StudentInfo();
          }
        },
      ),
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
            fontWeight: FontWeight.w600,
            fontSize: 16
          ),
        ),
        useMaterial3: true
      ),
    );
  }
}
