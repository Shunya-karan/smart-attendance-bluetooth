import 'package:flutter/material.dart';
import 'package:smart_attendance_bluetooth/student/student_home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_attendance_bluetooth/student/student_main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentInfo extends StatefulWidget{
  const StudentInfo ({super.key});


  @override
  State<StudentInfo> createState() => _StudentInfoState();
}


class _StudentInfoState extends State<StudentInfo> {
  TextEditingController name = TextEditingController();
  TextEditingController studentId = TextEditingController();

Future<void> saveStudentInfo(String name, String studentId) async {
  final prefs = await SharedPreferences.getInstance();
    await prefs.setString("name", name);
    await prefs.setString("studentId", studentId);
    await prefs.setBool("Logged_in", true);
    
    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(builder: (context) => StudentMain()),
    );
  }

  void submit(String name, String studentId) async{
    if(name.isEmpty || studentId.isEmpty || name.trim().isEmpty || studentId.trim().isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all the details", style: TextStyle(color: Colors.red),))
      );
      return;
    }
    await fetchAndSaveStudent(context);
  }

  Future<void> fetchAndSaveStudent(BuildContext context) async {
  final doc = await FirebaseFirestore.instance
      .collection("students")
      .doc(studentId.text.trim()) 
      .get();

  if (!doc.exists) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("No student found with the given student ID", style: TextStyle(color: Colors.red),))
    );
    return;
  }

  if (doc.data()!["name"].toString().toLowerCase() != name.text.trim().toLowerCase()) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("The name does not match the student ID", style: TextStyle(color: Colors.red),))
    );
    return;
  }

  final data = doc.data()!;

  final prefs = await SharedPreferences.getInstance();
  await prefs.setString("name", data["name"].toString());
  await prefs.setString("studentId", data["seatNo"].toString());
  await prefs.setString("rollNo", data["rollNo"].toString());
  await prefs.setString("class", data["className"].toString());
  await prefs.setString("classId", data["classId"].toString());
  await prefs.setBool("Logged_in", true);

  ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Student information saved successfully", style: TextStyle(color: Colors.green),))
    );

  if (!context.mounted) return;
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => StudentMain()),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
      children: [
        Container(
          height: double.maxFinite,
          child: 
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 60),
              Icon(Icons.school_rounded,
                    size: 80,
                  color: Theme.of(context).colorScheme.primary,
                  ),
                  
                SizedBox(height: 15),
                
                Text(
                  "Welcome",
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 40),

                Text("Enter your details to continue",
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.grey
                ),
                textAlign: TextAlign.center,
                ),

                SizedBox(height: 20),

                TextField(
                  controller: name,
                  decoration: InputDecoration(
                    labelText: "Name",
                    hintText: "Enter your full name",
                    prefixIcon: Icon(Icons.person_2_rounded),
                    border: OutlineInputBorder(
                      borderSide:BorderSide(color: Colors.grey) ,
                      borderRadius: BorderRadius.circular(20)
                    )
                  ),
                ),

                SizedBox(height: 20),

                TextField(
                  controller: studentId,
                  decoration: InputDecoration(
                    labelText: "Student ID",
                    hintText: "Enter your student ID",
                    prefixIcon: Icon(Icons.badge_rounded),
                    border: OutlineInputBorder(
                      borderSide:BorderSide(color: Colors.grey) ,
                      borderRadius: BorderRadius.circular(20)
                    )
                  ),
                ),

                SizedBox(height: 20),
            ],
          )
        ),
      ),
        ),
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: ElevatedButton(
            onPressed: () => submit(name.text, studentId.text),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                ),
              backgroundColor: Theme.of(context).colorScheme.primary
              ),
            child: Text("Continue", style: TextStyle(fontSize: 16, color: Colors.white),),
          ),
        )
        ],
      ),
    );
  }
}