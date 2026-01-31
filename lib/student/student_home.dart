import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_attendance_bluetooth/student/student_profile.dart';
import 'student_info.dart';
import 'student_profile.dart';

class StudentHome extends StatefulWidget {
  const StudentHome({super.key});

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  bool isBtOn = false;
  bool dialogShown = false;
  String name = "";
  String seatNumber = "";

  @override
  void initState() {
    super.initState();
    initBluetooth();
    _checkStudentInfo();
  }

  Future<void> initBluetooth() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
    ].request();

    FlutterBluePlus.adapterState.listen((state) {
      if (!mounted) return;

      final btOn = state == BluetoothAdapterState.on;

      setState(() {
        isBtOn = btOn;
      });

      if (!btOn && !dialogShown) {
        dialogShown = true;
        _showBtDialog();
      }

      if (btOn) {
        dialogShown = false;
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      }
    });
  }

  void _showBtDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Bluetooth Required"),
        content: const Text("Please turn ON Bluetooth to continue attendance."),
        actions: [
          TextButton(
            onPressed: () {
              AppSettings.openAppSettings(type: AppSettingsType.bluetooth);
            },
            child: const Text("Turn On"),
          ),
        ],
      ),
    );
  }

  Future<void> _checkStudentInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final n1 = prefs.getString("name");
    final n2 = prefs.getString("seatNumber");

    if (n1 == null || n2 == null) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const StudentInfo()),
      );
    } else {
      if (!mounted) return;
      setState(() {
        name = n1;
        seatNumber = n2;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(height: 35, width: 280,
                        child: Text(
                          name.toUpperCase(),
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        ),
                        Container(height: 20, width: 280,
                        child: Text(
                          seatNumber,
                          style: TextStyle(
                            fontSize: 15 ,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        )
                        
                      ],
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => StudentProfile()));
                      },
                      icon: Icon(
                      Icons.person_rounded,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                      )
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(height: 100, width: 400,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent, width: 1.3),
                  borderRadius: BorderRadius.circular(12),
                  color: const Color.fromARGB(255, 236, 250, 255),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: 10,),
                    Icon(isBtOn ? Icons.bluetooth_rounded : Icons.bluetooth_disabled_rounded,
                      size: 40,
                      color: isBtOn ? Colors.blue : Colors.red,
                    ),
                    SizedBox(width: 10),
                    Text("Bluetooth",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(width: 145),
                    Switch(value: isBtOn, onChanged: (bool value) {
                      AppSettings.openAppSettings(type: AppSettingsType.bluetooth);
                    }),
                    SizedBox(width: 10,),
                  ],
                ),
                ),
                SizedBox(height: 20),

                Container(height: 100, width: 400,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent, width: 1.3),
                  borderRadius: BorderRadius.circular(12),
                  color: const Color.fromARGB(255, 236, 250, 255),

                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: 10,),
                    Icon(Icons.class_rounded,
                      size: 40,
                      color: const Color.fromARGB(255, 208, 195, 82),
                    ),
                    SizedBox(width: 10),
                    Text("Scan Session",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(width: 100),
                    ElevatedButton(onPressed: () {},
                     child: Text("Scan"),),
                    SizedBox(width: 10,),
                  ],
                ),
                ),
                SizedBox(height: 20),
                Container(height: 100, width: 400,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent, width: 1.3),
                  borderRadius: BorderRadius.circular(12),
                  color: const Color.fromARGB(255, 236, 250, 255),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 15,),
                        Icon(Icons.fact_check,
                          size: 20,
                          color: Colors.green,
                        ),
                        SizedBox(width: 10),
                        Text("Attendance",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 155),
                        TextButton(onPressed: () {},
                         child: Text("View All", style: TextStyle(
                          color: Colors.blue,
                         ),),)
                      ]
                    )
                  ],
                  ),
                ),
                SizedBox(height: 500),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.home_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 40,
                ),
              ),
              Text("Home", style: Theme.of(context).textTheme.titleSmall),
              
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => StudentProfile()));
                },
                icon: Icon(
                  Icons.person_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 40,
                ),
              ),
              Text("Profile", style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
        ],
      ),
    );
  }
}
