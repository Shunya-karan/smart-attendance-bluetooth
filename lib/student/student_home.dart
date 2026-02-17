import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'other_required.dart';
import 'student_info.dart';
import 'dart:async';

class StudentHome extends StatefulWidget {
  final VoidCallback onScan;
  final VoidCallback onProfile;
  final VoidCallback onAttendance;

  const StudentHome({
    super.key,
    required this.onScan,
    required this.onProfile,
    required this.onAttendance,
  });

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  final NetworkListener _networkListener = NetworkListener();
  bool isBtOn = false;
  bool dialogShown = false;
  String name = "";
  String seatNumber = "";
  bool net = false;
  int screenWidth = 0;

  @override
  void initState() {
    super.initState();
    initBluetoothUI();
    _checkStudentInfo();
    listenNet();
  }

  @override
  void dispose() {
    _networkListener.stop();
    super.dispose();
  }

  void initBluetoothUI() async {
    AppBluetoothService.adapterState().listen((state) {
      if (!mounted) return;

      final btOn = state == BluetoothAdapterState.on;

      setState(() => isBtOn = btOn);
    });
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

  void listenNet() {
    _networkListener.start((isOnline) {
      if (!mounted) return;
      setState(() => net = isOnline);
    });
  }

  Widget buildChart(int perc, String title) {
    return Container(
      height: 120,
      width: 100,
      color: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularPercentIndicator(
            radius: 40,
            lineWidth: 10,
            percent: perc / 100,
            center: Text("$perc %"),
            progressColor: perc >= 80 && perc <= 100
                ? Colors.green
                : perc >= 75 && perc < 80
                ? Colors.orange
                : Colors.red,
            backgroundColor: Colors.grey.shade300,
            circularStrokeCap: CircularStrokeCap.round,
          ),
          SizedBox(height: 5),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildListTile(String subject, String time, bool present) {
    return ListTile(
      leading: Icon(
        present ? Icons.check_rounded : Icons.close_rounded,
        size: 30,
        color: present ? Colors.green : Colors.red,
        weight: 2000,
      ),
      title: Text(
        subject,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      subtitle: Text(time, style: TextStyle(fontSize: 16, color: Colors.grey)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [ 
          SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: widget.onProfile,
                    child: const CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage('assets/profile.png'),
                    ),
                  ),

                  const SizedBox(width: 15),

                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        seatNumber,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    children: [
                      Icon(
                        net ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                        size: 40,
                        color: net ? Colors.green : Colors.red,
                      ),
                      Text(
                        net ? "Online" : "Offline",
                        style: TextStyle(
                          color: net ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 10),
                ],
              ),

              Divider(color: Colors.grey, thickness: 1),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Attendance", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                  
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  AppSettings.openAppSettings(type: AppSettingsType.bluetooth);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isBtOn ? Colors.blue.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isBtOn ? Colors.blue : Colors.red,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.bluetooth,
                        size: 16,
                        color: isBtOn ? Colors.blue : Colors.red,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isBtOn ? "Bluetooth ON" : "Bluetooth OFF",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isBtOn ? Colors.blue : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
                ],
              ),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent, width: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  color: const Color.fromARGB(255, 236, 250, 255),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(2, 2),
                      blurRadius: 5,
                      color: Colors.grey,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    Row(
                      children: [
                        SizedBox(width: 15),
                        Icon(
                          Icons.today_rounded,
                          size: 24,
                          color: const Color.fromARGB(255, 203, 124, 183),
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Today's Attendance",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    buildListTile("Mathematics", "9:00 AM - 10:00 AM", true),
                    buildListTile("IoT", "10:15 AM - 11:15 AM", false),
                    buildListTile(
                      "Data Structures",
                      "11:30 AM - 12:30 PM",
                      true,
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                height: 370,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent, width: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  color: const Color.fromARGB(255, 236, 250, 255),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 15),
                        Icon(Icons.fact_check, size: 20, color: Colors.green),
                        SizedBox(width: 10),
                        Text(
                          "Attendance",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 155),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            "View All",
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        buildChart(net ? 90 : 0, "Overall"),
                        SizedBox(width: 20),
                        buildChart(net ? 77 : 0, "This Month"),
                        SizedBox(width: 20),
                        buildChart(net ? 50 : 0, "This Week"),
                      ],
                    ),
                    SizedBox(width: 20),
                    Divider(
                      color: Colors.grey,
                      thickness: 1,
                      indent: 10,
                      endIndent: 10,
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Text("Max"),
                            SizedBox(height: 7),
                            buildChart(net ? 100 : 0, net ? "Maths" : "Null"),
                          ],
                        ),
                        SizedBox(width: 40),
                        Column(
                          children: [
                            Text("Min"),
                            SizedBox(height: 7),
                            buildChart(net ? 10 : 0, net ? "IoT" : "Null"),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 100),
            ],
          ),
        ),
        Positioned(
  bottom: 16,
  left: 0,
  right: 0,
  child: Center(
    child: SizedBox(
      width: 250, // 👈 control button width here
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
  colors: [
    Color(0xFF2193B0),
    Color(0xFF6DD5ED),
  ],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
)
,

          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: widget.onScan,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text(
            "Scan Session",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    ),
  ),
),

        ],
      ),
    );
  }
}
