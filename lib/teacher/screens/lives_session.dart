import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smart_attendance_bluetooth/teacher/widgets/heading&subheading.dart';
import 'package:smart_attendance_bluetooth/bluetooth_session.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LivesSession extends StatefulWidget {
    final DateTime startTime;
    final int durationMinutes;
    final String sessionCode;
    final String className;
    final String subjectName;
    final String sessionType;


   LivesSession({super.key,
     required this.startTime,
     required this.durationMinutes,
     required this.sessionType,
     required this.className,
     required this.sessionCode,
     required this.subjectName
  });


  @override
  State<LivesSession> createState() => _LivesSessionState();
}

class _LivesSessionState extends State<LivesSession> {
    Timer?_timer;
    late DateTime endTime;
    Duration remaining=Duration.zero;
    final List<String> presentStudents = ['68'];
    
    


@override
void initState() {
  super.initState();

  endTime = widget.startTime.add(
    Duration(minutes: widget.durationMinutes),
  );

  remaining = endTime.difference(DateTime.now());
  _startCountdown();

  /// 🔥 LISTEN BLE ATTENDANCE
  TeacherBleService.listenAttendance((data) {
  final parts = data.trim().split('|');

  final rollNo = parts.last.trim(); // "24"

  if (!presentStudents.contains(rollNo)) {
    setState(() {
      presentStudents.add(rollNo);
    });
  }
});


}

Future<List<Map<String, dynamic>>> getStudentsOfClass(String classId) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('students')
      .where('classId', isEqualTo: classId)
      .get();

  return snapshot.docs.map((doc) => doc.data()).toList();
}

Future<List<Widget>> createListTiles() async {
  final students = await getStudentsOfClass('classId1');
  return students.map((s) => ListTile(
    title: Text(s['name']),
    subtitle: Text('Roll No: ${s['rollNo']}'),
  )).toList();
}



void _startCountdown() {
  _timer?.cancel();
  _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    final now = DateTime.now();
    final diff = endTime.difference(now);

    if (diff.isNegative || diff.inSeconds == 0) {
      timer.cancel();

      /// 🔴 STOP BLE
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Heading_subheading(Heading: "Live Attendance", subheading: "Session is active • Marking students automatically"),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsetsGeometry.all(20),
                child: Column(
                  children: [
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
                              "Live Session",
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
                        _buildInfoRow(Icons.timer, "Duration", "${widget.durationMinutes}"),
                      ],
                    ),
                  ),
                ),
                    SizedBox(height: 20,),
 Card(
  elevation: 4,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
  ),
  child: Padding(
    padding: const EdgeInsets.all(12.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title of the card
        Text(
          'Student List', // <-- Your title here
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        SizedBox(height: 10), // spacing between title and list

        // StreamBuilder showing the list
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('students')
              .where('className', isEqualTo: 'SYCS')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final students = snapshot.data!.docs;

            if (students.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(child: Text('No students found')),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: students.map((doc) {
                final s = doc.data()! as Map<String, dynamic>;
                final isPresent = presentStudents.contains(
  s['rollNo'].toString().trim(),
);


                return ListTile(
                  title: Text(
                    s['name'].toString().toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: Text('Roll No: ${s['rollNo']}'),
                  trailing: isPresent
                      ? Icon(Icons.check_circle, color: Colors.green)
                      : Icon(Icons.remove_circle_outline, color: Colors.grey),
                );
              }).toList(),
            );
          },
        ),
      ],
    ),
  ),
),

                    SizedBox(height: 20,),
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
                                  formatDuration(remaining),
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: remaining.inSeconds > 10 ? Colors.green : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 25,),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(onPressed: ()async{
                                await TeacherBleService.stopBleSession();
                                  Navigator.pop(context);
                              },
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
                    
                ],
                ),
              ),
            ),
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

