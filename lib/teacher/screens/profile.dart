import 'package:flutter/material.dart';
import 'package:smart_attendance_bluetooth/services/firebase_teacher.dart';

class TeacherProfile extends StatefulWidget {
  const TeacherProfile({super.key});

  @override
  State<TeacherProfile> createState() => _TeacherProfileState();
}

class _TeacherProfileState extends State<TeacherProfile> {
  final firebaseservices = FirebaseService();

  String teacherName = "";
  String email = "";
  String role = "";
  String department = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTeacherDetails();
  }

  Future<void> fetchTeacherDetails() async {
    final doc = await firebaseservices.fetchTeacherDetails();

    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      setState(() {
        teacherName = data["name"] ?? "";
        email = data["email"] ?? "";
        role = data["role"] ?? "";
        department = data["department"] ?? "";
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void logout() async {
    await firebaseservices.logout();

    // Go back to login screen
    Navigator.pushReplacementNamed(context, "/login");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Teacher Profile"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator()
              : Padding(
            padding: const EdgeInsets.all(20),
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      child: Icon(Icons.person, size: 40),
                    ),
                    const SizedBox(height: 15),

                    Text(
                      teacherName,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),

                    Text(role),
                    Text(department),
                    const SizedBox(height: 10),
                    Text(email),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: logout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: Text("Logout",
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.white )
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}