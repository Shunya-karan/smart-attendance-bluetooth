import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_attendance_bluetooth/services/firebase_teacher.dart';
import 'package:smart_attendance_bluetooth/teacher/screens/lives_session.dart';
import 'package:smart_attendance_bluetooth/teacher/widgets/dateAndtime.dart';
import 'package:smart_attendance_bluetooth/teacher/widgets/heading&subheading.dart';
import 'package:intl/intl.dart';
class attendanceHistory extends StatefulWidget {
  const attendanceHistory({super.key});

  @override
  State<attendanceHistory> createState() => _attendanceHistoryState();
}

class _attendanceHistoryState extends State<attendanceHistory> {
  final firebaseServices=FirebaseService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Heading_subheading(
              Heading: "Attendance History",
              subheading: "Track attendance across recent sessions",
            ),
            Padding(
              padding: const EdgeInsets.only(right: 18.0, top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  DateandTime(),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: StreamBuilder(
                stream: firebaseServices.getSessionHistory(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return const Center(child: Text("No sessions found"));
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      var data = docs[index];
                      String sessionId = data.id;
                      DateTime dateTime = (data['createdAt'] as Timestamp).toDate();
                      String formattedDate = DateFormat('dd-MM-yyyy HH:mm').format(dateTime);
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => LivesSession(
                                    startTime: (data["createdAt"] as Timestamp).toDate(),
                                    durationMinutes: 60,
                                    sessionType: data["sessiontype"],
                                    className: data["class"],
                                    sessionCode: sessionId,
                                    subjectName: data["subject"],
                                    isHistory: true,
                                  ),
                                ),
                              );
                            },
                            title: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Session Code: $sessionId",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.class_, size: 18, color: Colors.grey[700]),
                                    const SizedBox(width: 6),
                                    Text("Class: ${data['class']}"),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.book, size: 18, color: Colors.grey[700]),
                                    const SizedBox(width: 6),
                                    Text("Subject: ${(data['subject']).toString().length>25?(data['subject']).toString().substring(0,22):data['subject']}..."),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.category, size: 18, color: Colors.grey[700]),
                                    const SizedBox(width: 6),
                                    Text("Type: ${data['sessiontype']}"),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today, size: 18, color: Colors.grey[700]),
                                    const SizedBox(width: 6),
                                    Text("Date: ${formattedDate}"),
                                  ],
                                ),
                              ],
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
