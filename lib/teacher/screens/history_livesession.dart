import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_attendance_bluetooth/services/firebase_teacher.dart';
import 'package:smart_attendance_bluetooth/teacher/screens/lives_session.dart';
import 'package:smart_attendance_bluetooth/teacher/widgets/dateAndtime.dart';
import 'package:smart_attendance_bluetooth/teacher/widgets/heading&subheading.dart';
import 'package:intl/intl.dart';
class his_liveSession extends StatefulWidget {
  const his_liveSession({super.key});

  @override
  State<his_liveSession> createState() => _his_liveSessionState();
}

class _his_liveSessionState extends State<his_liveSession> {
  final firebaseServices=FirebaseService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Heading_subheading(
              Heading: "Active Session",
              subheading: "Track attendance which is active",
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
                stream: firebaseServices.getLiveSession(),
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
                                    durationMinutes: data["duration"],
                                    sessionType: data["sessionType"],
                                    className: data["className"],
                                    sessionCode: sessionId,
                                    subjectName: data["subjectName"],
                                    isHistory: false,
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
                                    Text("Class: ${data['className']}"),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.book, size: 18, color: Colors.grey[700]),
                                    const SizedBox(width: 6),
                                    Text("Subject: ${(data['subjectName']).toString().length>25?(data['subjectName']).toString().substring(0,22):data['subjectName']}..."),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.category, size: 18, color: Colors.grey[700]),
                                    const SizedBox(width: 6),
                                    Text("Type: ${data['sessionType']}"),
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
