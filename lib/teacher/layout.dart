import 'package:flutter/material.dart';
import 'package:smart_attendance_bluetooth/teacher/screens/dashboard.dart';
import 'package:smart_attendance_bluetooth/teacher/screens/profile.dart';


class teacher_Layout extends StatefulWidget {
  const teacher_Layout({super.key});

  @override
  State<teacher_Layout> createState() => _teacher_LayoutState();
}

class _teacher_LayoutState extends State<teacher_Layout> {
  int currentpage=0;
  List<Widget>Pages=[
    TeacherDashboard(),
    TeacherProfile()
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentpage,
        children:Pages,
      ),
      bottomNavigationBar:BottomNavigationBar(
          selectedFontSize: 14,
          unselectedFontSize: 10,
          selectedItemColor: Colors.teal,
          iconSize: 40,
          onTap: (value){
            setState(() {
              currentpage=value;
            });
          },
          currentIndex: currentpage,
          items:[BottomNavigationBarItem(
              icon: Icon(Icons.home
              ),
              label: "Home"
          ),
            BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: "Profile",
            )
          ]) ,
    );
  }
}
