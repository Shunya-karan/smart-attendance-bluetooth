import 'package:firebase_auth/firebase_auth.dart';

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
}
