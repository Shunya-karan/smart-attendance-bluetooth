import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  Future <UserCredential>loginTeacher(String email, String password) async {
    return await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential>signupTeacher(String email,String password)async{
    return await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
  }

  Stream<QuerySnapshot>departmentList(){
    return  FirebaseFirestore.instance
        .collection("departments")
        .where("isActive")
        .orderBy("name")
        .snapshots();

  }

  Stream<QuerySnapshot>allClasses(){
    return FirebaseFirestore.instance
        .collection("classes")
        .where("isActive", isEqualTo: true)
        .snapshots();
  }


  Stream<QuerySnapshot>Subjects(selectedClassId){
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
      "teacherBtName": "SMART_ATTEND_TEACHER_01"
    });

    return sessionCode;
  }


  Future<QuerySnapshot> subjectCode(String? classID) {
    return FirebaseFirestore.instance
        .collection("classes")
        .doc(classID)
        .collection("subjects")
        .where("isActive", isEqualTo: true)
        .get();
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


}
