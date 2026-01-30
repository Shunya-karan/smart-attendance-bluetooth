import 'package:flutter/material.dart';

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
                    Icons.person_add_alt_1_outlined,
                    color: Theme.of(context).colorScheme.secondary,
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
                            Icons.history_outlined,
                            color: Theme.of(context).colorScheme.secondary,
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
                            Icons.school,
                            color: Theme.of(context).colorScheme.secondary,
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
                            Icons.class_rounded,
                            color:Theme.of(context).colorScheme.secondary,
                            size: 30,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 3,),
                  Text(
                    "Class\n",
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
                            Icons.report_gmailerrorred_outlined,
                            color: Theme.of(context).colorScheme.secondary,
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
                            color: Theme.of(context).colorScheme.secondary,
                            size: 30,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 3,),
                  Text(
                    "Live\nSession",
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
                            Icons.create,
                            color:Theme.of(context).colorScheme.secondary,
                            size: 30,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 3,),
                  Text(
                    "Create\nClass",
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
                            Icons.import_export,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 30,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 3,),
                  Text(
                    "Import\nCSV",
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
                            Icons.import_export_sharp,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 30,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 3,),
                  Text(
                    "Export\nAttendance",
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
