import 'package:flutter/material.dart';
import 'package:smart_attendance_bluetooth/student/student_home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentInfo extends StatefulWidget{
  const StudentInfo ({super.key});


  @override
  State<StudentInfo> createState() => _StudentInfoState();
}


class _StudentInfoState extends State<StudentInfo> {
  TextEditingController name = TextEditingController();
  TextEditingController seatNumber = TextEditingController();

Future<void> saveStudentInfo(String name, String seatNumber) async {
  final prefs = await SharedPreferences.getInstance();
    await prefs.setString("name", name);
    await prefs.setString("seatNumber", seatNumber);
    await prefs.setBool("Logged_in", true);
    
    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(builder: (context) => StudentHome()),
    );
  }

  submit(String name, String seatNumber) async{
    if(name.isEmpty || seatNumber.isEmpty || name.trim().isEmpty || seatNumber.trim().isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all the details", style: TextStyle(color: Colors.red),))
      );
      return;
    }
    await saveStudentInfo(name, seatNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 10),
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
                    hintText: "Enter your name",
                    prefixIcon: Icon(Icons.person_2_rounded),
                    border: OutlineInputBorder(
                      borderSide:BorderSide(color: Colors.grey) ,
                      borderRadius: BorderRadius.circular(20)
                    )
                  ),
                ),

                SizedBox(height: 20),

                TextField(
                  controller: seatNumber,
                  decoration: InputDecoration(
                    labelText: "Seat Number",
                    hintText: "Enter your seat number",
                    prefixIcon: Icon(Icons.badge_rounded),
                    border: OutlineInputBorder(
                      borderSide:BorderSide(color: Colors.grey) ,
                      borderRadius: BorderRadius.circular(20)
                    )
                  ),
                ),

                SizedBox(height: 20),

                TextField(
                  decoration: InputDecoration(
                    labelText: "Class",
                    hintText: "Enter your class",
                    prefixIcon: Icon(Icons.groups_rounded),
                    border: OutlineInputBorder(
                      borderSide:BorderSide(color: Colors.grey) ,
                      borderRadius: BorderRadius.circular(20)
                    )
                  ),
                ),

                SizedBox(height: 271,),

                ElevatedButton(
                  onPressed: () async {
                    await submit(name.text, seatNumber.text);
                  },
                 style: ElevatedButton.styleFrom(
                   backgroundColor: Theme.of(context).colorScheme.primary,
                   foregroundColor: Colors.white,
                   padding: EdgeInsets.symmetric(vertical: 16),
                   shape: RoundedRectangleBorder(
                     borderRadius: BorderRadius.circular(10),
                   ),
                   elevation: 2,
                 ),
                 child: Text("Continue",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                  ),
                 ),
                ),
            ],
          )
        ),
      ),
      ),
    );
  }
}