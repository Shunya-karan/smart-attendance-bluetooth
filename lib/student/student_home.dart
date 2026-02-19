import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'other_required.dart';
import 'student_info.dart';
import 'dart:async';
import '../services/firebase_student.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:io';

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
  final StudentFirebaseService service = StudentFirebaseService();
  final NetworkListener _networkListener = NetworkListener();
  bool isBtOn = false;
  bool dialogShown = false;
  String name = "";
  String seatNumber = "";
  bool net = false;
  int screenWidth = 0;
  bool showOfflineOverride = false;
  String? photo;


  @override
  void initState() {
    super.initState();
    initBluetoothUI();
    _checkStudentInfo();
    clearOfflineIfDateChanged();
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

  static Future<(String?, String?, String?)> _getStudentInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final n1 = prefs.getString("name");
    final n2 = prefs.getString("seatNumber");
    final p = prefs.getString("photoPath");

    return (n1, n2, p);
  }

  void _checkStudentInfo() async {
    final (n1, n2, p) = await _getStudentInfo();

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
        photo = p;
      });
    }
  }


  Future<void> clearOfflineIfDateChanged() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString("offline_date");
    final today = DateTime.now().toIso8601String().substring(0, 10);

    if (savedDate != today) {
      await prefs.setString("offline_date", today);
      await prefs.remove("offline_sessions");
    }
  }

  void listenNet() {
    _networkListener.start((isOnline) {
      if (!mounted) return;
      setState(() {
        net = isOnline;

        if (!net) {
          showOfflineOverride = true;
        } else {
          showOfflineOverride = false;
        }
      });
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

  Widget buildListTile(
    String subject,
    String sessionType,
    String time,
    bool present,
  ) {
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
      subtitle: Text(
        "$sessionType" + time,
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }

  Widget attendanceChart(String title, DateTime? start, DateTime? end) {
    return FutureBuilder<int>(
      future: service.getAttendancePercentage(
        seatNumber,
        startDate: start,
        endDate: end,
      ),
      builder: (context, snapshot) {
        final perc = snapshot.data ?? 0;
        return buildChart(perc, title);
      },
    );
  }

  Future<List<String>> getOfflineSessions() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList("offline_sessions") ?? [];
  }

  Widget todayCard() {
    final bool showOffline = !net || showOfflineOverride;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent, width: 0.2),
        borderRadius: BorderRadius.circular(12),
        color: const Color.fromARGB(255, 236, 250, 255),
        boxShadow: const [
          BoxShadow(offset: Offset(2, 2), blurRadius: 5, color: Colors.grey),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                const Icon(
                  Icons.today_rounded,
                  size: 24,
                  color: Color.fromARGB(255, 203, 124, 183),
                ),
                const SizedBox(width: 10),
                const Text(
                  "Today's Attendance",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),

                if (net)
                  IconButton(
                    tooltip: showOffline
                        ? "Show online attendance"
                        : "Show offline attendance",
                    icon: Icon(
                      showOffline ? Icons.cloud_off : Icons.cloud_done,
                      size: 18,
                      color: showOffline ? Colors.grey : Colors.green,
                    ),
                    onPressed: () {
                      setState(() {
                        showOfflineOverride = !showOfflineOverride;
                      });
                    },
                  )
                else
                  const Icon(Icons.cloud_off, size: 18, color: Colors.grey),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(15, 4, 15, 8),
            child: Text(
              showOffline
                  ? "Showing offline attendance"
                  : "Showing online attendance",
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

          const SizedBox(height: 10),

          showOffline ? _offlineAttendanceList() : _onlineAttendanceList(),

          const SizedBox(height: 20),

          if (showOffline && !net)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.grey),
                SizedBox(width: 5),
                Text(
                  "Suggestion: Connect to internet to fetch online attendance",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _offlineAttendanceList() {
    return FutureBuilder<List<String>>(
      future: getOfflineSessions(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          );
        }

        final sessions = snapshot.data!;

        if (sessions.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Text(
                "No lecture attended today",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        return Column(
          children: sessions.map((session) {
            final parts = session.split("|");
            return buildListTile(
              parts[0].trim(),
              "",
              parts.length > 1 ? parts[1].trim() : "",
              true,
            );
          }).toList(),
        );
      },
    );
  }

  Widget _onlineAttendanceList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: StudentFirebaseService.getTodayAttendance(seatNumber),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          );
        }

        final sessions = snapshot.data!;
        if (sessions.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Text(
                "No lecture attended today",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        return Column(
          children: sessions.map((s) {
            final subject = s["subject"] ?? "Unknown";
            final time = s["time"] != null
                ? DateFormat(
                    'hh:mm a',
                  ).format((s["time"] as DateTime).toLocal())
                : "";
            final present = s["present"] ?? false;
            final sessionType = s["sessionType"] ?? "";
            return buildListTile(
              "$subject",
              sessionType + "           ",
              time,
              present,
            );
          }).toList(),
        );
      },
    );
  }

  Widget minANDmax(String classId, String m) {
    return FutureBuilder<Map<String, int>>(
      future: service.getSubjectWiseAttendance(seatNumber, classId),
      builder: (context, snapshot) {
        final data = snapshot.data ?? {"Null" : 0};

        final maxEntry = data.entries.reduce(
          (a, b) => a.value >= b.value ? a : b,
        );
        final minEntry = data.entries.reduce(
          (a, b) => a.value <= b.value ? a : b,
        );

        if (m == "max")
          return buildChart(maxEntry.value, maxEntry.key);
        else
          return buildChart(minEntry.value, minEntry.key);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
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
                        child: CircleAvatar(
                          radius: 30,
                          backgroundImage: photo != null
                              ? FileImage(File(photo!))
                              : AssetImage('assets/profile.png'),
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
                            overflow: TextOverflow.ellipsis,
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
                          SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "VES",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(
                                net
                                    ? Icons.wifi_rounded
                                    : Icons.wifi_off_rounded,
                                size: 15,
                                color: net ? Colors.green : Colors.red,
                              ),
                              SizedBox(width: 5),
                              Text(
                                net ? "Online" : "Offline",
                                style: TextStyle(
                                  color: net ? Colors.green : Colors.red,
                                ),
                              ),
                            ],
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
                      Text(
                        "Attendance",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),

                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          AppSettings.openAppSettings(
                            type: AppSettingsType.bluetooth,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isBtOn
                                ? Colors.blue.shade50
                                : Colors.red.shade50,
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
                  todayCard(),
                  SizedBox(height: 20),
                  Container(
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
                            Icon(
                              Icons.fact_check,
                              size: 20,
                              color: Colors.green,
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Attendance",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Spacer(),
                            TextButton(
                              onPressed: widget.onAttendance,
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
                            attendanceChart(
                              "Overall",
                              null,
                              null,
                            ), // no filter = all time
                            SizedBox(width: 20),
                            attendanceChart(
                              "This Month",
                              DateTime(
                                DateTime.now().year,
                                DateTime.now().month,
                                1,
                              ),
                              null,
                            ),
                            SizedBox(width: 20),
                            attendanceChart(
                              "This Week",
                              DateTime.now().subtract(
                                Duration(days: DateTime.now().weekday - 1),
                              ),
                              null,
                            ),
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
                                const Text("Max"),
                                SizedBox(height: 7),
                                minANDmax("classId1", "max"),
                              ],
                            ),
                            SizedBox(width: 40),
                            Column(
                              children: [
                                const Text("Min"),
                                SizedBox(height: 7),
                                minANDmax("classId1", "min"),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
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
                  width: 250,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2193B0), Color(0xFF6DD5ED)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),

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
      ),
    );
  }
}
