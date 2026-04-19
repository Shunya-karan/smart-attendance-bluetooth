import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';
import 'student/student_main.dart';
import 'student/student_info.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const StudentApp());
}

Future<bool> hasStudentInfo() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString("name") != null &&
      prefs.getString("studentId") != null;
}

class StudentApp extends StatelessWidget {
  const StudentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Student App",
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
          }

          return const StudentInfo();
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
                fontWeight: FontWeight.w500,
                fontSize: 16
            ),
          ),
          useMaterial3: true
      ),
    );
  }
}
