import 'package:flutter/material.dart';
import 'package:smart_attendance_bluetooth/student/student_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class StudentProfile extends StatefulWidget {
  const StudentProfile({super.key});

  @override
  State<StudentProfile> createState() => _StudentProfileState();
}

class _StudentProfileState extends State<StudentProfile> {
  String name = "";
  String seatNumber = "";
  String? photoPath;

   @override
  void dispose() {
    super.dispose();
  }


  @override
  void initState() {
    super.initState();
    _checkStudentInfo();
  }

  Future<void> _checkStudentInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final n1 = prefs.getString("name");
    final n2 = prefs.getString("seatNumber");
    final p = prefs.getString("photoPath");

    setState(() {
      name = n1 ?? "";
      seatNumber = n2 ?? "";
      photoPath = p;
    });
  }

  final ImagePicker picker = ImagePicker();

Future<void> pickProfilePhoto() async {
  final XFile? image = await picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 70,
  );

  if (image == null) return;

  final prefs = await SharedPreferences.getInstance();
  await prefs.setString("photoPath", image.path);

  setState(() {
    photoPath = image.path;
  });
}


  Future<void> logout() async {
    final pref = await SharedPreferences.getInstance();
    await pref.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => StudentInfo()),
      (route) => false,
      );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
                        onTap: () {
                          pickProfilePhoto();
                        },
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: photoPath != null
                              ? FileImage(File(photoPath!))
                              : AssetImage('assets/profile.png'),
                        ),
                      ),

            SizedBox(height: 10),
            Text(
              "Student",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: 30),
            Container(
              width: 300,
              height: 200,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),  
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Name :  " + name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Seat Number :  " + seatNumber,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text("Class :  SYCS", style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  )),
                  SizedBox(height: 20),
                  Text("College :  VESASC", style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  )),
                ],
              ),

            ),
            SizedBox(height: 30),
            ElevatedButton(onPressed: logout,
             style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 2,
             ),
             child: Text("Logout", style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold)),
             
            ),
            SizedBox(height: 40),
          ],
        )
    );
  }
}
