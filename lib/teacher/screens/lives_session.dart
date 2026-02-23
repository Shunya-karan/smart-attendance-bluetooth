import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_attendance_bluetooth/teacher/widgets/heading&subheading.dart';
import 'package:smart_attendance_bluetooth/services/firebase_teacher.dart';
import 'package:smart_attendance_bluetooth/bluetooth_session.dart';

class LivesSession extends StatefulWidget {
  final DateTime startTime;
  final int durationMinutes;
  final String sessionCode;
  final String className;
  final String subjectName;
  final String sessionType;
  final bool isHistory;

  LivesSession({super.key,
    required this.startTime,
    required this.durationMinutes,
    required this.sessionType,
    required this.className,
    required this.sessionCode,
    required this.subjectName,
    required this.isHistory
  });

  @override
  State<LivesSession> createState() => _LivesSessionState();
}

class _LivesSessionState extends State<LivesSession> {
  Timer?_timer;
  late DateTime endTime;
  Duration remaining=Duration.zero;
  Map<String, bool> attendanceMap = {};
  final FirebaseServices=FirebaseService();
  List presentStudents=[];
  List studentsList = [];

  @override
void initState() {
  super.initState();

  endTime = widget.startTime.add(
    Duration(minutes: widget.durationMinutes),
  );

  remaining = endTime.difference(DateTime.now());

  if (widget.isHistory) {
    loadOldAttendance();
  } else {
    _startCountdown();
    TeacherbleServices();
  }
}

  void TeacherbleServices() {
  TeacherBleService.listenAttendance((data) {
    if (data.isEmpty) return;

    final rollNo = data.trim();

    for (var student in studentsList) {
      if (student["rollNo"].toString() == rollNo) {
        final studentId = student.id;

        if (attendanceMap[studentId] == true) return;

        setState(() {
          attendanceMap[studentId] = true;
        });
        break;
      }
    }
  });
}


  Future<void> loadOldAttendance() async {
    final snap = await FirebaseFirestore.instance
        .collection("attendance_records")
        .doc(widget.sessionCode)
        .collection("students")
        .get();

    for (var doc in snap.docs) {
      attendanceMap[doc.id] = doc["present"];
    }

    setState(() {});
  }




void _startCountdown() {
  _timer?.cancel();
  _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    final now = DateTime.now();
    final diff = endTime.difference(now);

    if (diff.isNegative || diff.inSeconds == 0) {
      timer.cancel();
      TeacherBleService.stopBleSession();
      setState(() {
        remaining = Duration.zero;
      });
      return;
    }

    setState(() {
      remaining = diff;
    });
  });
}

@override
void dispose() {
  _timer?.cancel();
  TeacherBleService.stopBleSession();
  super.dispose();
}


  String formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  void _endSession(){
    showDialog(context: context,
        builder:(_)=>AlertDialog(
          title: Text("End Session?"),
          content: Text("Do you want to end the session \nSession Code : ${widget.sessionCode}?"),
          actions: [
            TextButton(onPressed:()=> Navigator.pop(context),
                child: Text("Cancel",
                  style: TextStyle(color: Colors.red),)
            ),
            ElevatedButton(onPressed: (){
              _timer?.cancel();
              FirebaseServices.endSession(widget.sessionCode);
              setState(() {
                remaining=Duration(seconds: 0);
                Navigator.pop(context);
              });
            },
                child: Text("Yes"))
          ],
        ));

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            //Heading and Back button
            Heading_subheading(Heading:!widget.isHistory?"Live Attendance":"Past Attendance", subheading: "Session is active • Marking students automatically"),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsetsGeometry.all(20),
                child: Column(
                  children: [
                    //Details of session
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  !widget.isHistory?
                                  "Live Session":"Past Session",
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                                Chip(
                                  label: Text("Active"),
                                  backgroundColor: Colors.green.shade100,
                                  labelStyle: TextStyle(color: Colors.green.shade800),
                                ),
                              ],
                            ),
                            const Divider(height: 20, thickness: 1),
                            _buildInfoRow(Icons.qr_code, "Session Code", "${widget.sessionCode}"),
                            _buildInfoRow(Icons.class_outlined, "Class", "${widget.className}"),
                            _buildInfoRow(Icons.menu_book, "Subject", "${widget.subjectName}"),
                            _buildInfoRow(Icons.laptop, "Session type", "${widget.sessionType}"),
                            _buildInfoRow(Icons.access_time, "Start Time", "${widget.startTime}"),
                            _buildInfoRow(Icons.timer, "Duration", !widget.isHistory?"${widget.durationMinutes} Minute":"0"),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 20,),

                    //Timer for Ending session
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(20)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.access_time,color: Theme.of(context).colorScheme.primary,),
                                SizedBox(width: 10,),
                                Text("Session will end in:",style:Theme.of(context).textTheme.titleMedium?.
                                copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800]
                                ),),
                                SizedBox(width: 10,),
                                Text(
                                  !widget.isHistory?
                                  formatDuration(remaining):"00:00",
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: remaining.inSeconds > 10? Colors.green : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 25,),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(onPressed: _endSession,
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red.shade600,
                                    foregroundColor: Colors.white,
                                    padding:EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadiusGeometry.circular(12)
                                    )
                                ),
                                icon: Icon(Icons.stop_circle_outlined),
                                label: Text("End Session",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16
                                  ),),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 30,),
                    //Student names and Roll numbers
                    StreamBuilder(
                      stream: FirebaseServices.getStudents(widget.className),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return CircularProgressIndicator();

                        final students = snapshot.data!.docs;
                        studentsList =students;

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: students.length,
                          itemBuilder: (context, index) {
                            final student = students[index];
                            final studentId = student.id;

                            // default false if not set
                            bool present = attendanceMap[studentId] ?? false;
                            return Card(
                              elevation: 2,
                              child: ListTile(
                                title: Text(
                                  student["name"].toString().toUpperCase(),
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                subtitle: Text(
                                  "Roll No : ${student["rollNo"]}",
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                trailing: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      attendanceMap[studentId] = !present;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: present ? Colors.green : Colors.red,
                                  ),
                                  child: Text(
                                    present ? "P" : "A",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    )
                  ],
                ),
              ),
            ),

            //Save Button
            Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                  color: Colors.grey[100]
              ),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: ElevatedButton(
                    onPressed:()async{
                      await FirebaseServices.saveAttendance(
                        sessionType: widget.sessionType,
                        subject: widget.subjectName,
                        className: widget.className,
                        date: widget.startTime,
                        sessionId: widget.sessionCode,
                        attendanceMap: attendanceMap,
                        students:studentsList,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Attendance Saved Successfully\nSessionCode :${widget.sessionCode}"),
                        duration: Duration(seconds: 4),
                      ));
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[400],
                        elevation: 10
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.save_alt,size: 30,color: Colors.white,),
                        SizedBox(width: 10,),
                        Text("Save",
                          style:Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white
                          ),
                        ),
                      ],
                    )),
              ),
            )
          ],
        ),

      ),
    );
  }
}

Widget _buildInfoRow(IconData icon, String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      children: [
        Icon(icon),
        const SizedBox(width: 12),
        Text(
          "$label : ",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: Colors.black87),
          ),
        ),
      ],
    ),
  );
}
