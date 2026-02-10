import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_attendance_bluetooth/services/firebase_service.dart';
import 'package:smart_attendance_bluetooth/teacher/screens/lives_session.dart';
import 'package:smart_attendance_bluetooth/teacher/widgets/blutooth_status.dart';
import 'package:smart_attendance_bluetooth/teacher/widgets/dateAndtime.dart';
import 'package:smart_attendance_bluetooth/teacher/widgets/heading&subheading.dart';
import 'package:smart_attendance_bluetooth/bluetooth_session.dart';

class StartAttendance extends StatefulWidget {
    const StartAttendance({super.key});

  @override
  State<StartAttendance> createState() => _StartAttendanceState();

}

class _StartAttendanceState extends State<StartAttendance> {
  bool scanReady = false;
  String? selectedClassId;
  String ?selectedSubjectId;
  String? selectedClassName;
  String? selectedSubjectName;
  List<int> sessionDuration=[1,2,3,4,5,6,7,8,9,10];
  int ? selectedDuration;
  String?sessionType;
  String?sessionCode;
  final FirebaseServices=FirebaseService();



  Future<String> generateSessionCode() async {
    final rand = Random();
    final number = 999 + rand.nextInt(9000);

    String c = selectedClassName!.replaceAll(" ", "").toUpperCase();

final docSnapshot = await FirebaseFirestore.instance
    .collection('classes')
    .doc('classId1')
    .collection('subjects')
    .doc('sub1')
    .get();

if (!docSnapshot.exists) {
  throw Exception("Subject not found");
}

final s = docSnapshot['code']; 

    sessionCode = "$c|$s|$number";
    print(sessionCode! +'wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww');

    return "${sessionCode}";
  }


  // Future <void>_startSession()async{
  //   if(selectedClassId==null||
  //       selectedSubjectId==null||
  //       selectedDuration==null){
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Please fill session details"))
  //     );
  //     return;
  //   }

  //   final sessionId = await FirebaseServices.createAttendanceSession(
  //     classId: selectedClassId!,
  //     className: selectedClassName!,
  //     subjectId: selectedSubjectId!,
  //     subjectName: selectedSubjectName!,
  //     duration: selectedDuration!,
  //     sessionType: sessionType!,
  //     teacherId: FirebaseAuth.instance.currentUser!.uid,
  //     sessionCode: await generateSessionCode(),
  //   );

  //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //       content:Text("Session started ${await generateSessionCode()}"
  //       )
  //   )
  //   );
  //   Navigator.pushReplacement(context, MaterialPageRoute(builder:(context)=>
  //     LivesSession(
  //       startTime: DateTime.now(),
  //       durationMinutes: 2,
  //       subjectName: selectedSubjectName!,
  //       className: selectedClassName!,
  //       sessionCode:sessionCode!,
  //     sessionType: sessionType!,
  //     )
  //   ));


  // }

Future<void> _startSession() async {
  if (selectedClassId == null ||
      selectedSubjectId == null ||
      selectedDuration == null ||
      sessionType == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please fill session details")),
    );
    return;
  }

  final code = await generateSessionCode();

      print(code);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:Text("Session started $code"
        )
    )
    );

  await FirebaseServices.createAttendanceSession(
    classId: selectedClassId!,
    className: selectedClassName!,
    subjectId: selectedSubjectId!,
    subjectName: selectedSubjectName!,
    duration: selectedDuration!,
    sessionType: sessionType!,
    teacherId: FirebaseAuth.instance.currentUser!.uid,
    sessionCode: code,
  );

  /// 🔥 START BLE HERE
  await TeacherBleService.startBleSession(
    sessionCode: code,
  );

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => LivesSession(
        startTime: DateTime.now(),
        durationMinutes: selectedDuration!,
        subjectName: selectedSubjectName!,
        className: selectedClassName!,
        sessionCode: code,
        sessionType: sessionType!,
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Heading Box
            Heading_subheading(
              Heading: "Start Attendance",
              subheading: "Create a new session and start",
            ),
            // Date&Time
            Padding(
              padding: const EdgeInsets.only(right: 18.0,top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  DateandTime(),
                ],
              )
            ),
            //Create session Container
            SizedBox(height: 10,),
            Expanded(
                child:SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BluetoothStatusCard(
                        onStatusChanged: (ready) {
                          setState(() {
                            scanReady=ready;
                          });
                        },
                      ),

                      SizedBox(height: 16,),
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.grey)
                        ),
                        child: Padding(
                            padding: EdgeInsetsGeometry.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding:  EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.event_note_rounded,
                                      color: Colors.blue[700],
                                      size: 24,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                      "Session Details",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                  ),
                                ],

                              ),
                              SizedBox(height: 24,),
                              StreamBuilder(stream: FirebaseServices.allClasses(),
                                  builder: (context,snapshot) {
                                    if(!snapshot.hasData) return CircularProgressIndicator();
                                    final docs=snapshot.data!.docs;
                                    return DropdownButtonFormField(
                                      initialValue: selectedClassId,
                                      items: docs.map((doc){
                                        return DropdownMenuItem(
                                            value: doc.id,
                                            child: Text(doc["name"],
                                            style: TextStyle(fontWeight: FontWeight.normal),)
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        final selectedDoc = docs.firstWhere((doc) => doc.id == val);

                                        setState(() {
                                          selectedClassId = val;
                                          selectedClassName = selectedDoc["name"];                                           selectedSubjectId = null;
                                          selectedSubjectId = null;
                                          selectedSubjectName = null;
                                        });
                                      },

                                      decoration: InputDecoration(
                                        label: Text("Class",style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.normal
                                        )
                                        ),
                                        hint: Text("Select Class",style: TextStyle(
                                            fontWeight: FontWeight.normal,fontSize: 12
                                        ),
                                        ),
                                        prefixIcon: const Icon(Icons.class_outlined),
                                        filled: true,
                                        fillColor: Colors.grey[50],
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(color: Colors.blueAccent, width: 1.2),
                                        ),
                                      ),
                                    );
                                  }),
                              SizedBox(height: 20,),
                              StreamBuilder(
                                  stream: FirebaseServices.Subjects(selectedClassId),
                                  builder: (context,snapshot) {
                                    if(!snapshot.hasData) return CircularProgressIndicator();
                                    final docs=snapshot.data!.docs;
                                    if (selectedClassId == null) {
                                      return DropdownButtonFormField(
                                        items: [],
                                        onChanged: null,
                                        decoration: InputDecoration(
                                          prefixIcon: Icon(Icons.error,color: Colors.red[900],),
                                          label: Text("Select class for subjects",
                                              style:Theme.of(context).textTheme.titleMedium?.copyWith(
                                                  fontWeight: FontWeight.normal,color: Colors.red[900]
                                              )),
                                          hint: Text("Subject",
                                              style:Theme.of(context).textTheme.titleMedium?.copyWith(
                                                  fontWeight: FontWeight.normal,color: Colors.red[900]
                                              )),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: const BorderSide(color: Colors.blueAccent, width: 1.2),
                                            ),
                                          filled: true,
                                          fillColor: Colors.grey[50],
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                        ),
                                      );
                                    }
                                    return DropdownButtonFormField(
                                      initialValue: selectedSubjectId,
                                      items: docs.map((doc){
                                        return DropdownMenuItem(
                                            value: doc.id,
                                            child: Text((doc["name"]).length>20?"${(doc["name"]).substring(0,20)}...":doc["name"],
                                            style: TextStyle(fontWeight: FontWeight.normal),)
                                        );
                                      }).toList(),
                                      onChanged:(val) {
                                        final selectedDoc=docs.firstWhere((doc)=>doc.id==val);
                                        setState(() {
                                          selectedSubjectId=val;
                                          selectedSubjectName=selectedDoc["name"];
                                        });
                                      },
                                      decoration: InputDecoration(
                                        label: Text("Subjects",style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.normal)
                                        ),
                                        prefixIcon: const Icon(Icons.subject_outlined),
                                        filled: true,
                                        fillColor: Colors.grey[50],
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(color: Colors.blueAccent, width: 1.2),
                                        ),
                                      ),
                                    );
                                  }),
                              SizedBox(height: 20,),
                              DropdownButtonFormField<int>(
                              initialValue: selectedDuration,
                                items:sessionDuration.map((e){
                                  return DropdownMenuItem(
                                      child: Text("${e} Minute",
                                          style: TextStyle(fontWeight: FontWeight.normal)),
                                      value: e);
                                }).toList(),
                                onChanged: (val){
                                setState(() {
                                  selectedDuration=val;
                                });
                                },
                                decoration:InputDecoration(
                                  label: Text("Duration",style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.normal)
                              ),
                                  hint: Text("Select Session Duration",
                                      style:Theme.of(context).textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.normal)
                                  ),
                                  prefixIcon: const Icon(Icons.timelapse_outlined),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Colors.blueAccent, width: 1.2),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20,),
                              Text("Session Type :",
                              style: Theme.of(context).textTheme.titleSmall,),
                              RadioMenuButton(value:"Lecture" ,
                                  groupValue:sessionType ,
                                  onChanged:(val){
                                setState(() {
                                  sessionType=val;
                                });
                                  },
                                  child:Text("Lecture") ),
                              RadioMenuButton(value:"Practical" ,
                                  groupValue:sessionType ,
                                  onChanged:(val){
                                    setState(() {
                                      sessionType=val;
                                    });
                                  },
                                  child:Text("Practical") ),
                              RadioMenuButton(value:"Tutorial" ,
                                  groupValue:sessionType ,
                                  onChanged:(val){
                                    setState(() {
                                      sessionType=val;
                                    });
                                  },
                                  child:Text("Tutorial") ),

                            ],
                          ),

                        ),
                      ),

                    ],
                  ),
                )
            ),
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200]
              ),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: ElevatedButton(onPressed:scanReady?_startSession :null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[400],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.slow_motion_video,color: Colors.white,size: 25,),
                        SizedBox(width: 10,),
                        Text("Start Attendance Session"
                        ,style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white
                          ),
                        ),
                      ],
                    )),
              ),
            )

          ],
        ),
      ),
    );
  }
}



