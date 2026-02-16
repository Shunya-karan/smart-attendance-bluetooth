import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_attendance_bluetooth/teacher/widgets/QuickAction.dart';
import 'package:smart_attendance_bluetooth/teacher/widgets/Statscard.dart';
import 'package:smart_attendance_bluetooth/teacher/widgets/blutooth_status.dart';
import 'package:smart_attendance_bluetooth/teacher/widgets/notification.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  String teacherName="";


  Future<void> fetchTeacherName() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection("teachers")
        .doc(uid)
        .get();

    if (doc.exists) {
      setState(() {
        teacherName = doc["name"];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchTeacherName();
  }

  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: 20),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w400
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                            teacherName.isEmpty ? "Loading..." : teacherName,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            letterSpacing: 0.7
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 100),
                    // Icon(Icons.school,
                    // size: 70,color: Theme.of(context).colorScheme.primary,),
                  ],
                ),
              ),
              SizedBox(height: 10),

              //Bluetooth Status
              BluetoothStatusCard(),
              //Notification

              NotificationBox(message: "Next Session At 10:00 Am in SYCS class",),

              // Stats cards
              Container(
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.white30,
                ),
                // color: Colors.white54,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    SizedBox(height: 10,),
                    Text("Stats",
                    style: Theme.of(context).textTheme.titleMedium,),
                    SizedBox(height: 10,),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          StatsCard(
                            heading: "Sessions Today",
                            totalCount: "20",
                            cardColor: Color.fromRGBO(69, 154, 251, 1.0),
                            statsIcons: Icons.school_outlined,
                          ),
                          SizedBox(width: 10),
                          StatsCard(
                            heading: "Last Session Present",
                            totalCount: "20",
                            cardColor: Color.fromRGBO(23, 159, 88, 1.0),
                            statsIcons: Icons.co_present_outlined,
                          ),
                          SizedBox(width: 10),
                          StatsCard(
                            heading: "Last Session Absent",
                            totalCount: "20",
                            cardColor: Color.fromRGBO(186, 0, 0, 1.0),
                            statsIcons: Icons.hourglass_empty_outlined,
                          ),
                          SizedBox(width: 10),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30,),

              Text("Quick Actions",
                style: Theme.of(context).textTheme.titleMedium,),
              SizedBox(height: 10,),
              Container(
                height: 430,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: Offset(0,6),
                      color: Color(0x14000000)
                    ),
                  ],
                  // border: Border.all(color: Colors.tealAccent.shade200)
                ),

                child: QuickAction()
              ),

            ],
          ),

        ),
      ),


    );
  }
}