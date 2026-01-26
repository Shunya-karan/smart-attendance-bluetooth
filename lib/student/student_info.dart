import 'package:flutter/material.dart';

class StudentInfo extends StatefulWidget{
  const StudentInfo ({super.key});

  @override
  State<StudentInfo> createState() => _StudentInfoState();
}

class _StudentInfoState extends State<StudentInfo> {
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
              SizedBox(height: 100),
              Icon(Icons.school_rounded,
                    size: 80,
                  color: Theme.of(context).colorScheme.primary,
                  ),
                  
                SizedBox(height: 24),
                
                Text(
                  "Welcome Back!",
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 70),

                Text("Enter your seat number to continue",
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.grey
                ),
                textAlign: TextAlign.center,
                ),

                SizedBox(height: 24),

                TextField(
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

                SizedBox(height: 320,),

                ElevatedButton(onPressed: () {},
                 child: Text("Login"),
                 style: ElevatedButton.styleFrom(
                   backgroundColor: Theme.of(context).colorScheme.primary,
                   foregroundColor: Colors.white,
                   padding: EdgeInsets.symmetric(vertical: 16),
                   shape: RoundedRectangleBorder(
                     borderRadius: BorderRadius.circular(10),
                   ),
                   elevation: 2,
                 )
                ),

            ],
          )
        ),
      ),
      ),
    );
  }
}