import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  //Authentication
  Future <UserCredential>loginTeacher(String email, String password) async {
    return await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential>signupTeacher(String email,String password)async{
    return await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }


  //Teacher details
  Future<DocumentSnapshot>fetchTeacherDetails()async{
      final uid=FirebaseAuth.instance.currentUser!.uid;
      return await FirebaseFirestore.instance
          .collection("teachers")
          .doc(uid)
          .get();
  }

  //Department list
  Stream<QuerySnapshot>departmentList(){
    return  FirebaseFirestore.instance
        .collection("departments")
        .where("isActive")
        .orderBy("name")
        .snapshots();

  }

  //all class
  Stream<QuerySnapshot>allClasses(){
    return FirebaseFirestore.instance
        .collection("classes")
        .where("isActive", isEqualTo: true)
        .snapshots();
  }

  //all subject in particular class
  Stream<QuerySnapshot>Subjects(selectedClassId){
    return FirebaseFirestore.instance
        .collection("classes")
        .doc(selectedClassId)
        .collection("subjects")
        .where("isActive")
        .snapshots();
  }

  //Attnadnce session
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
      "endTime":"" ,
      "status": "active",
      "createdAt": FieldValue.serverTimestamp(),
      "presentCount":0
    });

    return sessionCode;
  }

  Future<void>endSession(String?sessionId){
    return FirebaseFirestore.instance
        .collection("attendance_sessions")
        .doc(sessionId)
        .update({
      "status":"closed",
      "endTime":FieldValue.serverTimestamp()
    });
  }

  //subject code for session code
  Future<String?> getSubjectCode(String?classId, String?subjectId) async {
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

  //student details
  Stream<QuerySnapshot> getStudents(String className) {
    return FirebaseFirestore.instance
        .collection('students')
        .where('className', isEqualTo: className.toLowerCase())
        .snapshots();
  }

  //Save or update attendance
  Future<void> saveAttendance({
    required String sessionId,
    required String className,
    required String subject,
    required String sessionType,
    required DateTime date,
    required Map<String, bool> attendanceMap,
    required List students,
  }) async {
    final sessionRef =
    firestore.collection("attendance_records").doc(sessionId);
    final sessionDoc = await sessionRef.get();
    final uid = FirebaseAuth.instance.currentUser!.uid;
    if (!sessionDoc.exists) {
      await sessionRef.set({
        "teacherId": uid,
        "class": className,
        "subject": subject,
        "sessiontype": sessionType,
        "date": date, // store as Timestamp (BEST)
        "createdAt": FieldValue.serverTimestamp(),
      });
    } else {
      await sessionRef.update({
        "class": className,
        "subject": subject,
        "sessiontype": sessionType,
        "date": date, // update date if changed
      });
    }
    final batch = firestore.batch();

    for (var student in students) {
      final studentId = student.id;
      final present = attendanceMap[studentId] ?? false;

      final docRef =
      sessionRef.collection("students").doc(studentId);

      batch.set(docRef, {
        "name": student["name"],
        "seatNo": student["seatNo"],
        "present": present,
        "markedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    await batch.commit();
  }

  //session history
  Stream<QuerySnapshot> getSessionHistory() {
    final TeacherId=FirebaseAuth.instance.currentUser!.uid;
    return firestore
        .collection("attendance_records")
    .where("teacherId",isEqualTo: TeacherId)
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getLiveSession() {
    final Teacherid=FirebaseAuth.instance.currentUser!.uid;
    return firestore
        .collection("attendance_sessions")
        .where("teacherId",isEqualTo: Teacherid)
        .where("status",isEqualTo: "active")
        .orderBy("createdAt", descending: true)
        .snapshots();
  }


  //stats
  Future<int> getTodaySessionCount() async {

    final uid = FirebaseAuth.instance.currentUser!.uid;

    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await FirebaseFirestore.instance
        .collection('attendance_sessions')   // ⭐ your collection
        .where('teacherId', isEqualTo: uid)  // current teacher
        .where('startTime', isGreaterThanOrEqualTo: startOfDay)
        .where('startTime', isLessThan: endOfDay)
        .get();

    return snapshot.docs.length;
  }

  Future<int> getTotalPresentToday() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay = startOfDay.add(const Duration(days: 1));

    int totalPresent = 0;

    /// Get only today's sessions of THIS teacher
    final sessionsSnapshot = await FirebaseFirestore.instance
        .collection('attendance_records')
        .where('teacherId', isEqualTo: uid)   // ⭐ filter teacher
        .where('createdAt', isGreaterThanOrEqualTo: startOfDay)
        .where('createdAt', isLessThan: endOfDay)
        .get();

    /// Loop through sessions
    for (var session in sessionsSnapshot.docs) {
      final studentsSnapshot = await session.reference
          .collection('students')
          .where('present', isEqualTo: true)
          .get();

      totalPresent += studentsSnapshot.docs.length;
    }

    return totalPresent;
  }

  Future<int> getTotalAbsentToday() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay = startOfDay.add(const Duration(days: 1));

    int totalAbsent = 0;

    /// Get only today's sessions of THIS teacher
    final sessionsSnapshot = await FirebaseFirestore.instance
        .collection('attendance_records')
        .where('teacherId', isEqualTo: uid)   // ⭐ filter teacher
        .where('createdAt', isGreaterThanOrEqualTo: startOfDay)
        .where('createdAt', isLessThan: endOfDay)
        .get();

    /// Loop through sessions
    for (var session in sessionsSnapshot.docs) {
      final studentsSnapshot = await session.reference
          .collection('students')
          .where('present', isEqualTo: false)
          .get();

      totalAbsent += studentsSnapshot.docs.length;
    }

    return totalAbsent;
  }
}