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
  Future<String>createAttendanceSession({
    required String classId,
    required String subjectId,
    required  int duration,
    required String sessionType,
    required String teacherId,
    required String sessionId

})async{
    final doc=FirebaseFirestore.instance
        .collection("attendance_sessions")
        .doc();

    await doc.set({
      "classId":classId,
      "subjectId":subjectId,
      "duration":duration,
      "teacherId":teacherId,
      "startTime":FieldValue.serverTimestamp(),
      "endTime":null,
      "status":"active",
      "createdAt":FieldValue.serverTimestamp(),
      "sessionid":sessionId

    });
    return sessionId;
  }

  Future<QuerySnapshot> subjectCode(String? classID) {
    return FirebaseFirestore.instance
        .collection("classes")
        .doc(classID)
        .collection("subjects")
        .where("isActive", isEqualTo: true)
        .get();
  }


}
