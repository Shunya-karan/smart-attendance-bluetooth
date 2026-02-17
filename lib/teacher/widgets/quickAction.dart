import 'package:flutter/material.dart';
import 'package:smart_attendance_bluetooth/teacher/screens/allclass.dart';
import 'package:smart_attendance_bluetooth/teacher/screens/attendance_history.dart';
import 'package:smart_attendance_bluetooth/teacher/screens/start_attendance.dart';

class QuickAction extends StatelessWidget {
  const QuickAction({super.key});

  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width;
    final spacing = screenWidth > 420.0 ? 50.0 : screenWidth>400?45.0:25.0;

    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              //Start Attendance Button
              Column(
          children: [
          SizedBox(
          height: 60,
            width: 80,
            child: ElevatedButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>
                StartAttendance()));
                },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                elevation: 3,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_add_alt_1,
                    color: Colors.green,
                    size: 30,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 3,),
          Text(
            "Start\nAttendance",
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.normal,
              fontSize: 15
            ),
          ),
        ],
      ),

              SizedBox(width: spacing,),
              Column(
                children: [
                  SizedBox(
                    height: 60,
                    width: 80,
                    child: ElevatedButton(
                      onPressed:()=>Navigator.push(context,
                          MaterialPageRoute(builder: (context)=>attendanceHistory())),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        elevation: 3,
                        shadowColor: Colors.black26,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history_sharp,
                            color: Colors.redAccent,
                            size: 30,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 3,),
                  Text(
                    "Attendance\nHistory",
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.normal,
                      fontSize: 15
                    ),
                  ),
                ],
              ),

              //Attendance History Button
              SizedBox(width: spacing,),
              Column(
                children: [
                  SizedBox(
                    height: 60,
                    width: 80,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        elevation: 3,
                        shadowColor: Colors.black26,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.school_rounded,
                            color: Colors.blueAccent,
                            size: 30,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 3,),
                  Text(
                    "Students\n",
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.normal,
                      fontSize: 15

                    ),
                  ),
                ],
              ),

            ],
          ),

            SizedBox(height: 20,),
          Row(
            children: [
              //Start Attendance Button
              Column(
                children: [
                  SizedBox(
                    height: 60,
                    width: 80,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder:
                                (context)=>AllSubjects()
                            )
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        elevation: 3,
                        shadowColor: Colors.black26,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.menu_book_sharp,
                            color:Colors.blue,
                            size: 30,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 3,),
                  Text(
                    "Subjects\n",
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.normal,
                        fontSize: 15
                    ),
                  ),
                ],
              ),

              SizedBox(width: spacing,),
              Column(
                children: [
                  SizedBox(
                    height: 60,
                    width: 80,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        elevation: 3,
                        shadowColor: Colors.black26,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.report_gmailerrorred,
                            color: Colors.orange,
                            size: 30,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 3,),
                  Text(
                    "Reports\n",
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.normal,
                        fontSize: 15
                    ),
                  ),
                ],
              ),

              //Attendance History Button
              SizedBox(width: spacing,),
              Column(
                children: [
                  SizedBox(
                    height: 60,
                    width: 80,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        elevation: 3,
                        shadowColor: Colors.black26,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.live_tv,
                            color: Colors.purpleAccent,
                            size: 30,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 3,),
                  Text(
                    "Live\nSessions",
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.normal,
                        fontSize: 15

                    ),
                  ),
                ],
              ),

            ],
          ),

          SizedBox(height: 20,),
          Row(
            children: [
              Column(
                children: [
                  SizedBox(
                    height: 60,
                    width: 80,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        elevation: 3,
                        shadowColor: Colors.black26,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bluetooth,
                            color:Colors.pinkAccent,
                            size: 30,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 3,),
                  Text(
                    "Bluetooth\nPanel",
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.normal,
                        fontSize: 15
                    ),
                  ),
                ],
              ),

              SizedBox(width: spacing,),
              Column(
                children: [
                  SizedBox(
                    height: 60,
                    width: 80,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        elevation: 3,
                        shadowColor: Colors.black26,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_alert_rounded,
                            color: Colors.red[900],
                            size: 30,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 3,),
                  Text(
                    "Proxy\nAlerts",
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.normal,
                        fontSize: 15
                    ),
                  ),
                ],
              ),

            ],
          ),

        ],
      ),
    );
  }
}
