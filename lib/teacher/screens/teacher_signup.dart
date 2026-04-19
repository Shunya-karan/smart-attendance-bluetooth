import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_attendance_bluetooth/services/firebase_teacher.dart';
import 'package:smart_attendance_bluetooth/teacher/layout.dart';
import 'package:smart_attendance_bluetooth/teacher/screens/teacher_login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class TeacherSignup extends StatefulWidget {
  const TeacherSignup({super.key});

  @override
  State<TeacherSignup> createState() => _TeacherSignupState();
}


class _TeacherSignupState extends State<TeacherSignup> {
  final firebaseService= FirebaseService();
  bool _obsecurePassword = true;
  bool _ConfobsecurePassword = true;
  String? selectedDepartment;
  final passwordController=TextEditingController();
  final confirmPasswordController =TextEditingController();
  final nameController=TextEditingController();
  final emailController=TextEditingController();
  bool isLoading = false;

  @override
  void dispose(){
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
  void ClearingFields(){
    nameController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    emailController.clear();
    selectedDepartment = null;
  }
  void showMessage(String msg) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> createUserWithEmailAnsPassword() async{
    setState(() {
      isLoading = true;
    });

    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty ||
        confirmPasswordController.text.trim().isEmpty ||
        selectedDepartment == null) {
      showMessage("All fields are required");
      return;
    }
    else if(passwordController.text.trim()!=confirmPasswordController.text.trim()){
      showMessage("Passwords do not match");
      return;
    }
    else{
      try{
        final userCredential=await firebaseService.signupTeacher(emailController.text.trim(), passwordController.text.trim());
        final uid=userCredential.user!.uid;
        await FirebaseFirestore.instance.collection("teachers").doc(uid).set({
          "name":nameController.text.trim(),
          "email":emailController.text.trim(),
          "department":selectedDepartment,
          "role":"teacher",
          "createdAt":FieldValue.serverTimestamp(),
        });
        ClearingFields();
        if(!mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context)=>teacher_Layout()
        )
        );

      }on FirebaseAuthException catch(e){
        showMessage("${e.message}");
        return;
      }
      finally{
        if(mounted){
          setState(() => isLoading = false);
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
 // ---------------------- Welcome icon And text
                Icon(Icons.school_rounded,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(height: 24),
                //Welcome title
                Text(
                  "Welcome !",
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),

                Text("Create Account",
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.grey
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
// -------------------------Name-----------------
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                      labelText: "Name",
                      hintText: "Enter full name",
                      prefixIcon: Icon(Icons.drive_file_rename_outline),
                      border: OutlineInputBorder(
                          borderSide:BorderSide(color: Colors.grey) ,
                          borderRadius: BorderRadius.circular(20)
                      )
                  ),
                ),
                SizedBox(height: 16,),
 // ---------------------     Email-------------------------
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: InputDecoration(
                      labelText: "Email",
                      hintText: "Enter your email",
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                          borderSide:BorderSide(color: Colors.grey) ,
                          borderRadius: BorderRadius.circular(20)
                      )
                  ),
                ),
                SizedBox(height: 16,),
 // ----------------------- Password -----------
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
                SizedBox(height: 16,),
                TextField(
                  controller: confirmPasswordController ,
                  obscureText: _ConfobsecurePassword,
                  decoration: InputDecoration(
                    labelText: "Confirm Password",
                    hintText: "Enter Confirm password",
                    prefixIcon: Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _ConfobsecurePassword
                              ?Icons.visibility_outlined
                              :Icons.visibility_off_outlined
                      ),
                      onPressed: (){
                        setState(() {
                          _ConfobsecurePassword=!_ConfobsecurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                        borderSide:BorderSide(color: Colors.grey) ,
                        borderRadius: BorderRadius.circular(20)
                    ),

                  ),
                ),

// ----------------------Department Dropdown--------------
                SizedBox(height: 24),
              StreamBuilder(
                stream: firebaseService.departmentList(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(width: 50,height: 2,child: const CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text("No departments found");
                  }

                  final docs = snapshot.data!.docs;

                  return DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(20)
                      ),
                    ),
                    hint:Row(
                      children: [
                        Icon(Icons.school_outlined),
                        SizedBox(width: 20,),
                        Text("Choose department",
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.normal)
                        ),
                      ],
                    ),
                    initialValue: selectedDepartment,
                    items: docs.map((doc) {
                      return DropdownMenuItem<String>(
                        value: doc["name"],
                        child: Text((doc["name"]).length>30
                            ?"${(doc["name"]).substring(0,25)}...":doc["name"],
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.normal)
                        ),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => selectedDepartment = val),
                  );
                },
              ),
              SizedBox(height: 24),
 // ------------------Buttons-----------
                ElevatedButton(
                  onPressed:isLoading
                      ?null
                      :()async{
                    await createUserWithEmailAnsPassword();
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
                    height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 1,
                        color: Colors.white)
                  ):
                  Text("Sign up",
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
                      MaterialPageRoute(builder:(context)=>  TeacherLogin()
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
                        Text("Already have an account? Login now",
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Colors.blue
                          ),
                        ),
                        SizedBox(width: 5,),
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
