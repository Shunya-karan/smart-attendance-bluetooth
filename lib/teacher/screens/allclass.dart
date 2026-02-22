import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_attendance_bluetooth/services/firebase_teacher.dart';
import 'package:smart_attendance_bluetooth/teacher/widgets/heading&subheading.dart';

class AllSubjects extends StatefulWidget {
  const AllSubjects({super.key});

  @override
  State<AllSubjects> createState() => _AllSubjectsState();
}

class _AllSubjectsState extends State<AllSubjects> {
  final FirebaseServices=FirebaseService();
  String ?selectedClassId;
  String ?selectedClassName;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Heading_subheading(
              Heading: "Subjects",
              subheading: "Select Class for Subjects",
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseServices.allClasses(),
                      builder: (context, asyncSnapshot) {
                        if(!asyncSnapshot.hasData){
                          return CircularProgressIndicator();
                        }
                        final classes=asyncSnapshot.data!.docs;

                        return DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                          ),

                          hint: const Text("Select class"),
                          items: classes.map((doc) {
                            return DropdownMenuItem<String>(
                              value: doc.id,
                              child: Text(doc["name"]),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              selectedClassId = val;
                              selectedClassName=classes
                              .firstWhere((e)=>e.id==val)["name"];
                            });
                          },
                        );
                      }
                    ),
                    const SizedBox(height: 30),
                    if (selectedClassId != null)
                      StreamBuilder(
                        stream: FirebaseServices.Subjects(selectedClassId!),
                        builder: (context, asyncSnapshot) {
                          if(!asyncSnapshot.hasData){
                            return Center(child: CircularProgressIndicator());
                          }
                          final subjects=asyncSnapshot.data!.docs;
                          if(subjects.isEmpty){
                            return Center(child: Text("Subject Not Found"));
                          }
                          return ListView.builder(
                            shrinkWrap: true,
                            itemCount:subjects.length ,
                            itemBuilder: (context,index) {
                              final subject=subjects[index];
                              return ListTile(
                                leading: const Icon(Icons.book),
                                title: Text(subject["name"]),
                              );
                            },
                          );
                        }
                      )
                    else
                      const Text("Please select a class to see subjects"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}