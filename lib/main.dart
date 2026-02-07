import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_attendance_bluetooth/firebase_options.dart';
import 'package:smart_attendance_bluetooth/teacher/layout.dart';
import 'package:smart_attendance_bluetooth/teacher/screens/lives_session.dart';
import 'teacher/screens/teacher_login.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      title: "Attendance App",
      debugShowCheckedModeBanner: false,
      // home: FirebaseAuth.instance.currentUser!=null
      //     ? Center(
      //       child:teacher_Layout()
      //     ):TeacherLogin(),

      home:StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, asyncSnapshot){
          if(asyncSnapshot.connectionState==ConnectionState.waiting){
            return Center(
              child:CircularProgressIndicator() ,
            );
          }
         if(asyncSnapshot.data!=null){
           return LivesSession(
             startTime: DateTime.now(),
             durationMinutes:2,
             subjectName: "CN",
             className: "SYCS",
             sessionCode:"22",
             sessionType: "lecture",
           );
         }
      return TeacherLogin();
        }
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
