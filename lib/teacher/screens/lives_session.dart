import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smart_attendance_bluetooth/teacher/widgets/heading&subheading.dart';
import 'package:smart_attendance_bluetooth/bluetooth_session.dart';

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
    final List<String> presentStudents = [];
    


@override
void initState() {
  super.initState();

  endTime = widget.startTime.add(
    Duration(minutes: widget.durationMinutes),
  );

  remaining = endTime.difference(DateTime.now());
  _startCountdown();

  /// 🔥 LISTEN BLE ATTENDANCE
  TeacherBleService.listenAttendance((roll) {
    if (!presentStudents.contains(roll)) {
      setState(() {
        presentStudents.add(roll);
      });
    }
  });
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

