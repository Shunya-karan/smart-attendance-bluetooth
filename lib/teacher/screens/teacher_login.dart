import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_attendance_bluetooth/services/firebase_teacher.dart';
import 'package:smart_attendance_bluetooth/teacher/layout.dart';
import 'teacher_signup.dart';


class TeacherLogin extends StatefulWidget {
  const TeacherLogin ({super.key});

  @override
  State<TeacherLogin> createState() => _TeacherLoginState();
}

class _TeacherLoginState extends State<TeacherLogin> {
  final firebaseService=FirebaseService();
  bool _obsecurePassword = true;
  final passwordController=TextEditingController();
  final emailController = TextEditingController();
  bool isLoading=false;

  @override
  void dispose(){
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void showMessage(String msg){
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:Text(msg),
        duration: Duration(seconds: 3)
        ));
  }

  Future<void>loginUserwithEmailandPassword()async {
    setState(() {
      isLoading=true;
    });
    if (emailController.text
        .trim()
        .isEmpty ||
        passwordController.text
            .trim()
            .isEmpty) {
      showMessage("All fields are required");
      return;
    }
    else {
      try {
        await firebaseService.loginTeacher(
          emailController.text.trim(),
          passwordController.text.trim()
        );
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const teacher_Layout()),
        );
      } on FirebaseAuthException catch (e) {
        showMessage(e.message ?? "Login failed");
      }
      finally{
        if(mounted){
          setState(() {
            isLoading=false;
          });
        }
      }
    }
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
                //Welcome icon
                  Icon(Icons.school_rounded,
                    size: 80,
                  color: Theme.of(context).colorScheme.primary,
                  ),
                SizedBox(height: 24),
                //Welcome title
                Text(
                  "Welcome Back!",
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),

                Text("Login to continue",
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.grey
                ),
                textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),

                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: "Email",
                    hintText: "Enter your email",
                    prefixIcon: Icon(Icons.email_rounded),
                    border: OutlineInputBorder(
                      borderSide:BorderSide(color: Colors.grey) ,
                      borderRadius: BorderRadius.circular(20)
                    )
                  ),
                ),
                SizedBox(height: 16,),
                TextField(
                  controller: passwordController,
                  obscureText: _obsecurePassword,
                  decoration: InputDecoration(
                      labelText: "Password",
                      hintText: "Enter password",
                      prefixIcon: Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                            _obsecurePassword
                                ?Icons.visibility_outlined
                                :Icons.visibility_off_outlined
                        ),
                        onPressed: (){
                          setState(() {
                            _obsecurePassword=!_obsecurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                          borderSide:BorderSide(color: Colors.grey) ,
                          borderRadius: BorderRadius.circular(20)
                      ),

                  ),
                ),
                // SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(onPressed: (){},
                      child: Text("Forgot Password ?",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary
                      ),)),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed:isLoading?
                      null
                        :()async{
                   await loginUserwithEmailandPassword();
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
                  child: isLoading
                      ?SizedBox(
                    height: 20,width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2,color: Colors.white)
                  )
                      :Text("Log in",
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white
                  ),),
                ),
                SizedBox(height: 24,),

                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey,)),
                    Text("OR",
                    style: TextStyle(
                      color: Colors.grey,fontWeight: FontWeight.w500
                    ),
                    ),
                    Expanded(child: Divider(color: Colors.grey,)),
                  ],
                ),
                SizedBox(height: 24,),
                OutlinedButton(onPressed: (){
                  Navigator.push(context,
                      MaterialPageRoute(builder:(context)=>  TeacherSignup()
                  ));
                },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 1.5
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(10)
                      )
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("New Teacher ? Sign Up",
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.blue
                          ),
                        ),
                        Icon(Icons.arrow_forward_rounded,size: 20,)
                      ],
                    )
                ),
                SizedBox(height: 50,)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
