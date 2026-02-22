import 'package:flutter/material.dart';
import 'package:smart_attendance_bluetooth/student/student_attendance.dart';
import 'package:smart_attendance_bluetooth/student/student_home.dart';
import 'package:smart_attendance_bluetooth/student/student_profile.dart';
import 'package:smart_attendance_bluetooth/student/student_scan.dart';

class StudentMain extends StatefulWidget {
  @override
  State<StudentMain> createState() => _StudentMainState();
}

class _StudentMainState extends State<StudentMain> {
  int _index = 0;

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: IndexedStack(
      index: _index,
      children: [
        StudentHome(
          onScan: () => setState(() => _index = 1),
          onProfile: () => setState(() => _index = 3),
          onAttendance: () => setState(() => _index = 2),
        ),
        StudentScan(active: _index == 1? true : false, onBack: () => setState(() => _index = 0)),
        StudentAttendance(studentId: StudentHome.seatNumber, onBack: () => setState(() => _index = 0)),
        StudentProfile(onBack: () => setState(() => _index = 0)),
      ],
    ),
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: _index,
      onTap: (i) => setState(() => _index = i),
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color.fromARGB(255, 250, 255, 255),
      iconSize: 30,
      elevation: 5,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_rounded), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.class_outlined), activeIcon: Icon(Icons.class_rounded), label: "Session"),
        BottomNavigationBarItem(icon: Icon(Icons.fact_check_outlined), activeIcon: Icon(Icons.fact_check_rounded), label: "Attendance"),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person_rounded), label: "Profile"),
      ],
    ),
  );
}

}

