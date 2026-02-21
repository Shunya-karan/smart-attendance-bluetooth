import 'package:flutter/material.dart';
import 'package:smart_attendance_bluetooth/student/student_info.dart';
import 'package:smart_attendance_bluetooth/student/student_home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class StudentProfile extends StatefulWidget {
  final VoidCallback onBack;

  const StudentProfile({super.key, required this.onBack});

  @override
  State<StudentProfile> createState() => _StudentProfileState();
}

class _StudentProfileState extends State<StudentProfile> {
  String name = "";
  String studentId = "";
  String className = "";
  String classId = "";
  String rollNo = "";
  String? photoPath;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      details();
    });
  }

  void details() async {
    final (n1, n2, c1, c2, r, p) = await StudentHome.getStudentInfo();
    setState(() {
      name = n1 ?? "";
      studentId = n2 ?? "";
      className = c1 ?? "";
      classId = c2 ?? "";
      rollNo = r ?? "";
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

  Future<void> removeProfilePhoto() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("photoPath");

    if (!mounted) return;
    setState(() {
      photoPath = null;
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

  Widget profileRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 10),

          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[800], fontSize: 16),
            ),
          ),

          const Text(
            ":",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(width: 10),

          Expanded(
            flex: 5,
            child: Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDialog(String title, String content, String a) async{
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(a),
          ),
        ],
        ),
    );
    return confirm;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: widget.onBack,
                    icon: const Icon(Icons.arrow_back_ios_new),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Profile",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                ],
              ),
            ),
            SizedBox(height: 50),
            GestureDetector(
              onTap: () async {
                  if (photoPath != null){
                    final confirm = await _showDialog("Change photo?", "Do you want to change your profile photo?", "Change");
                  if (confirm == true) {
                    pickProfilePhoto();
                  } else {
                    null;
                  }
                  } else {
                    pickProfilePhoto();
                  }
                ;
              },

              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: photoPath != null
                    ? FileImage(File(photoPath!))
                    : AssetImage('assets/profile.png'),
              ),
               Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: photoPath != null ? Colors.red : Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () async{
                        if (photoPath != null) {
                          final confirm = await _showDialog("Remove photo?", "Do you want to remove your profile photo?", "Remove");
                  if (confirm == true) {
                    removeProfilePhoto();
                  } else {
                    null;
                  }
                        } else {
                          pickProfilePhoto();
                        }
                      },
                      icon: Icon(
                        photoPath != null ? Icons.close : Icons.camera_alt,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
                ],
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
              width: double.infinity,
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  profileRow("Name", name, Icons.person),
                  Divider(color: Colors.grey, endIndent: 5, indent: 5),
                  profileRow("Student ID", studentId, Icons.badge),
                  Divider(color: Colors.grey, endIndent: 5, indent: 5),
                  profileRow("Roll No", rollNo, Icons.format_list_numbered),
                  Divider(color: Colors.grey, endIndent: 5, indent: 5),
                  profileRow("Class", className.toUpperCase(), Icons.school),
                  Divider(color: Colors.grey, endIndent: 5, indent: 5),
                  profileRow("Class Id", classId, Icons.local_offer),
                  Divider(color: Colors.grey, endIndent: 5, indent: 5),
                  profileRow("College", "VESASC", Icons.account_balance),
                ],
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                final confirm = await _showDialog("Logout?", "Are you sure you want to logout?", "Logout");
                if (confirm == true) {
                  logout();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
              ),
              child: Text(
                "Logout",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
