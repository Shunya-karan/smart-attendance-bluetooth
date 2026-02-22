import 'package:cloud_firestore/cloud_firestore.dart';

class StudentFirebaseService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// 🔹 Get attendance of THIS student for ONE session
  /// 🔹 Get full student list for ONE session

  static Stream<List<Map<String, dynamic>>> getTodayAttendance(
    String rollNo, // pass as string like "24"
  ) async* {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final startTimestamp = Timestamp.fromDate(startOfDay);
    final endTimestamp = Timestamp.fromDate(endOfDay);

    // Listen to all attendance sessions created today
    await for (final sessionSnapshot
        in FirebaseFirestore.instance
            .collection("attendance_records")
            .where("createdAt", isGreaterThanOrEqualTo: startTimestamp)
            .where("createdAt", isLessThan: endTimestamp)
            .orderBy("createdAt", descending: true)
            .snapshots()) {
      List<Map<String, dynamic>> studentSessions = [];

      for (var sessionDoc in sessionSnapshot.docs) {
        // Each student's document has rollNo as doc ID
        final studentDoc = await sessionDoc.reference
            .collection("students")
            .doc(rollNo) // docId = rollNo
            .get();

        if (studentDoc.exists) {
          final studentData = studentDoc.data()!;
          studentSessions.add({
            "subject": sessionDoc["subject"] ?? "Unknown",
            "time": (sessionDoc["createdAt"] as Timestamp).toDate(), // DateTime
            "present": studentData["present"] ?? false,
            "sessionType": sessionDoc["sessiontype"] ?? "",
          });
        }
      }

      yield studentSessions;
    }
  }

  Future<int> getAttendancePercentage(
    String studentId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final snap = await firestore.collection("attendance_records").get();

    int total = 0;
    int present = 0;

    for (var session in snap.docs) {
      final createdAt = (session["createdAt"] as Timestamp).toDate();

      if (startDate != null && createdAt.isBefore(startDate)) continue;
      if (endDate != null && createdAt.isAfter(endDate)) continue;

      final doc = await session.reference
          .collection("students")
          .doc(studentId)
          .get();

      if (doc.exists) {
        total++;
        if (doc["present"] == true) present++;
      }
    }

    if (total == 0) return 0;
    return ((present / total) * 100).round();
  }

  /// 🔹 Subject-wise attendance percentage (NO type)
  Future<Map<String, int>> getSubjectWiseAttendance(String studentId, String classId) async {
  final snap = await firestore.collection("attendance_records").get();

  Map<String, int> total = {};
  Map<String, int> present = {};

  for (var session in snap.docs) {
    final subjectName = session.data()["subject"];
    if (subjectName == null) continue;

    // Get student attendance
    final studentDoc = await session.reference.collection("students").doc(studentId).get();
    if (!studentDoc.exists) continue;

    total[subjectName] = (total[subjectName] ?? 0) + 1;
    if (studentDoc["present"] == true) {
      present[subjectName] = (present[subjectName] ?? 0) + 1;
    }
  }

  // Get mapping of subject name → code
  final subjectSnapshot = await firestore
      .collection("classes")
      .doc(classId)
      .collection("subjects")
      .get();

  Map<String, String> nameToCode = {};
  for (var doc in subjectSnapshot.docs) {
    final data = doc.data();
    nameToCode[data["name"]] = data["code"] ?? data["name"];
  }

  // Calculate percentage and map name → code
  Map<String, int> percentage = {};
  total.forEach((subjectName, t) {
    final perc = ((present[subjectName] ?? 0) / t * 100).round();
    final code = nameToCode[subjectName] ?? subjectName; // fallback to name
    percentage[code] = perc;
  });

  return percentage;
}


  /// 🔥 Subject + SessionType attendance (Lecture / Practical / Tutorial)
  Future<Map<String, Map<String, int>>> getSubjectTypeAttendanceStats(
    String studentId,
  ) async {
    final snap = await firestore.collection("attendance_records").get();

    Map<String, int> total = {};
    Map<String, int> present = {};

    for (var session in snap.docs) {
      final subject = session.data()["subject"];
      final type = session.data()["sessiontype"];

      if (subject == null || type == null) continue;

      final key = "$subject | $type";

      final studentDoc = await session.reference
          .collection("students")
          .doc(studentId.toString().trim())
          .get();

      if (!studentDoc.exists) continue;

      total[key] = (total[key] ?? 0) + 1;

      if (studentDoc.data()?["present"] == true) {
        present[key] = (present[key] ?? 0) + 1;
      }
    }

    

    Map<String, Map<String, int>> result = {};

    total.forEach((key, t) {
      result[key] = {"total": t, "present": present[key] ?? 0};
    });

    return result;
  }

  Future<List<Map<String, dynamic>>> getDetailedAttendance({
    required String studentId,
    required String subject,
    required String sessionType,
  }) async {
    final snap = await firestore.collection("attendance_records").get();

    List<Map<String, dynamic>> records = [];

    for (var session in snap.docs) {
      if (session["subject"] != subject) continue;
      if (session["sessiontype"] != sessionType) continue;

      final studentDoc = await session.reference
          .collection("students")
          .doc(studentId)
          .get();

      if (!studentDoc.exists) continue;

      records.add({
        "date": session["date"],
        "present": studentDoc["present"] ?? false,
      });
    }

    return records;
  }
}
