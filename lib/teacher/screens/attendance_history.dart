import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_attendance_bluetooth/teacher/screens/lives_session.dart';
import 'package:smart_attendance_bluetooth/teacher/widgets/dateAndtime.dart';
import 'package:smart_attendance_bluetooth/teacher/widgets/heading&subheading.dart';

class attendanceHistory extends StatefulWidget {
  const attendanceHistory({super.key});

  @override
  State<attendanceHistory> createState() => _attendanceHistoryState();
}

class _attendanceHistoryState extends State<attendanceHistory> {
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
                stream: FirebaseFirestore.instance
                    .collection("attendance_records")
                    .orderBy("createdAt", descending: true)
                    .snapshots(),
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
                      return Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Card(
                          elevation: 2,
                          child: ListTile(
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Session Code: $sessionId"),
                                const SizedBox(height: 6),
                                Text("Class: ${data['class']}"),
                                Text("Subject: ${data['subject']}"),
                                Text("Type: ${data['sessiontype']}"),
                                Text("Date: ${data['date']}"),
                              ],
                            ),
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
