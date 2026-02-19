import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<UserCredential> loginTeacher(String email, String password) async {
    return await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signupTeacher(String email, String password) async {
    return await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Stream<QuerySnapshot> departmentList() {
    return FirebaseFirestore.instance
        .collection("departments")
        .where("isActive")
        .orderBy("name")
        .snapshots();
  }

  Stream<QuerySnapshot> allClasses() {
    return FirebaseFirestore.instance
        .collection("classes")
        .where("isActive", isEqualTo: true)
        .snapshots();
  }

  Stream<QuerySnapshot> Subjects(selectedClassId) {
    return FirebaseFirestore.instance
        .collection("classes")
        .doc(selectedClassId)
        .collection("subjects")
        .where("isActive")
        .snapshots();
  }

  Future<String> createAttendanceSession({
    required String classId,
    required String className,
    required String subjectId,
    required String subjectName,
    required int duration,
    required String sessionType,
    required String teacherId,
    required String sessionCode,
  }) async {
    final doc = FirebaseFirestore.instance
        .collection("attendance_sessions")
        .doc(sessionCode);

    await doc.set({
      "sessionCode": sessionCode,
      "classId": classId,
      "className": className,
      "subjectId": subjectId,
      "subjectName": subjectName,
      "duration": duration,
      "sessionType": sessionType,
      "teacherId": teacherId,
      "startTime": FieldValue.serverTimestamp(),
      "endTime": null,
      "status": "active",
      "createdAt": FieldValue.serverTimestamp(),
      "teacherBtName": "SMART_ATTEND_$sessionCode",
    });

    return sessionCode;
  }

  Future<String?> getSubjectCode(String? classId, String? subjectId) async {
    final doc = await FirebaseFirestore.instance
        .collection("classes")
        .doc(classId)
        .collection("subjects")
        .doc(subjectId)
        .get();

    if (doc.exists) {
      return doc.data()?["code"]; // field name = code
    }

    return null;
  }

  Future<void> endSession(String? sessionId) {
    return FirebaseFirestore.instance
        .collection("attendance_sessions")
        .doc(sessionId)
        .update({"status": "closed", "endTime": FieldValue.serverTimestamp()});
  }

  Stream<QuerySnapshot> getStudents(String? className) {
    return firestore
        .collection("students")
        .where("className", isEqualTo: className)
        .snapshots();
  }

  /// 🔵 Save or update attendance
  Future<void> saveAttendance({
    required String sessionId,
    required String className,
    required String subject,
    required String sessionType,
    required DateTime date,
    required Map<String, bool> attendanceMap,
    required List students,
  }) async {
    final sessionRef = firestore
        .collection("attendance_records")
        .doc(sessionId);
    // create/update session doc
    await sessionRef.set({
      "class": className,
      "subject": subject,
      "sessiontype": sessionType,
      "date": date.toIso8601String(),
      "createdAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    final batch = firestore.batch();
    for (var student in students) {
      final studentId = student.id;
      final present = attendanceMap[studentId] ?? false;

      final docRef = sessionRef.collection("students").doc(studentId);

      batch.set(docRef, {
        "name": student["name"],
        "rollNo": student["rollNo"],
        "present": present,
        "markedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    await batch.commit();
  }

  Future<Map<String, bool>> loadAttendance(String sessionId) async {
    final snap = await firestore
        .collection("attendance_records")
        .doc(sessionId)
        .collection("students")
        .get();

    Map<String, bool> map = {};

    for (var doc in snap.docs) {
      map[doc.id] = doc["present"] ?? false;
    }

    return map;
  }

  Stream<QuerySnapshot> getSessionHistory() {
    return firestore
        .collection("attendance_records")
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  Future<Map<String, Map<String, int>>> getSubjectTypeAttendanceStats(
    String studentId,
  ) async {
    final snap = await firestore.collection("attendance_records").get();

    Map<String, int> total = {};
    Map<String, int> present = {};

    for (var session in snap.docs) {
      final subject = session["subject"];
      final type = session["sessiontype"]; // Lecture / Practical / Tutorial

      final key = "$subject | $type";

      final studentDoc = await session.reference
          .collection("students")
          .doc(studentId)
          .get();

      if (!studentDoc.exists) continue;

      total[key] = (total[key] ?? 0) + 1;

      if (studentDoc["present"] == true) {
        present[key] = (present[key] ?? 0) + 1;
      }
    }

    Map<String, Map<String, int>> result = {};

    total.forEach((key, t) {
      result[key] = {"total": t, "present": present[key] ?? 0};
    });

    return result;
  }
}
