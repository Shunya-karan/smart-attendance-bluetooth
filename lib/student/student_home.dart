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

  const StudentHome({super.key,
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
                        Container(
                          height: 35,
                          width: 280,
                          child: Text(
                            name.toUpperCase(),
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        Container(
                          height: 20,
                          width: 280,
                          child: Text(
                            seatNumber,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: widget.onProfile,
                      icon: Icon(
                        Icons.person_rounded,
                        size: 80,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                Divider(
                  color: Colors.grey,
                  thickness: 1),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                AnimatedSwitcher(
  duration: Duration(milliseconds: 300),
  child: Text(
    net ? "Online" : "Offline",
    key: ValueKey(net),
    style: TextStyle(
      color: net ? Colors.green : Colors.red,
      fontWeight: FontWeight.bold,
    ),
  ),
),
                SizedBox(width: 20),
                  ]
                ),
                const SizedBox(height: 10),
                Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isBtOn ? Colors.blueAccent : Colors.redAccent,
                      width: 1.3,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: const Color.fromARGB(255, 236, 250, 255),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 10),
                      Icon(
                        isBtOn
                            ? Icons.bluetooth_rounded
                            : Icons.bluetooth_disabled_rounded,
                        size: 40,
                        color: isBtOn ? Colors.blue : Colors.red,
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Bluetooth",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 145),
                      Switch(
                        value: isBtOn,
                        onChanged: (bool value) {
                          AppSettings.openAppSettings(
                            type: AppSettingsType.bluetooth,
                          );
                        },
                      ),
                      SizedBox(width: 10),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent, width: 1.3),
                    borderRadius: BorderRadius.circular(12),
                    color: const Color.fromARGB(255, 236, 250, 255),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 10),
                      Icon(
                        Icons.class_rounded,
                        size: 40,
                        color: const Color.fromARGB(255, 208, 195, 82),
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Scan Session",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 100),
                      ElevatedButton(
                        onPressed: widget.onScan,

                        child: Text("Scan"),
                      ),
                      SizedBox(width: 10),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent, width: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    color: const Color.fromARGB(255, 236, 250, 255),
                    boxShadow: [BoxShadow(offset: Offset(2, 2), blurRadius: 5, color: Colors.grey)]
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
                          buildChart(net? 90:0, "Overall"),
                          SizedBox(width: 20),
                          buildChart(net? 77:0, "This Month"),
                          SizedBox(width: 20),
                          buildChart(net? 50:0, "This Week"),
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
                              buildChart(net? 100:0, net? "Maths":"Null"),
                            ],
                          ),
                          SizedBox(width: 40),
                          Column(
                            children: [
                              Text("Min"),
                              SizedBox(height: 7),
                              buildChart(net? 10:0, net? "IoT":"Null"),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                
              ],
            ),
          ),
        ),
    );
  }
}
