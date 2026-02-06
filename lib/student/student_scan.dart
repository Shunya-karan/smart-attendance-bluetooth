import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart';
import 'dart:async';
import 'package:smart_attendance_bluetooth/student/other_required.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';


class StudentScan extends StatefulWidget {
  final bool active;
  const StudentScan({super.key, required this.active});

  @override
  State<StudentScan> createState() => _StudentScanState();
}

class _StudentScanState extends State<StudentScan> {
  bool isBtOn = false;
  bool started = false;
  bool dialogShown = false;
  Map<String, Timer> timers = {};

  Map<String, int> sessionTimers = {
    "SESSION12345": 120,
    "SESSION1232234": 300,
    "SESSION98765": 0,
  };

  @override
  void initState() {
    super.initState();

    sessionTimers.forEach((id, time) {
      if (time > 0) {
        startTimer(id);
      }
    });
  }

  @override
  void dispose() {
    for (final timer in timers.values) {
      timer.cancel();
    }
    super.dispose();
  }

  @override
void didUpdateWidget(covariant StudentScan oldWidget) {
  super.didUpdateWidget(oldWidget);

  if (widget.active && !started) {
    started = true;
    initBluetoothUI();
  }

  if (!widget.active) {
    started = false;
  }
}



  void initBluetoothUI() async {
  await AppBluetoothService.requestPermissions();

  AppBluetoothService.adapterState().listen((state) {
    if (!mounted) return;

    final btOn = state == BluetoothAdapterState.on;

    setState(() => isBtOn = btOn);

    if (!btOn && !dialogShown) {
      dialogShown = true;
      _showBtDialog();
    }

    if (btOn && dialogShown) {
      Navigator.pop(context);
      dialogShown = false;
    }
  });
}
  void _showBtDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Bluetooth Required"),
          content: const Text(
            "Please turn ON Bluetooth to continue attendance.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                AppSettings.openAppSettings(type: AppSettingsType.bluetooth);
              },
              child: const Text("Turn On"),
            ),
          ],
        );
      },
    );
  }

  void startTimer(String sessionId) {
    // Cancel existing timer if any
    timers[sessionId]?.cancel();

    timers[sessionId] = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final current = sessionTimers[sessionId] ?? 0;

      if (current <= 0) {
        timer.cancel();
      } else {
        setState(() {
          sessionTimers[sessionId] = current - 1;
        });
      }
    });
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  Widget buildSession(String sessionID, String owner) {
    final timeLeft = sessionTimers[sessionID] ?? 0;

    return Container(
      width: 400,
      decoration: BoxDecoration(
        border: Border.all(
          color: timeLeft > 0
              ? Theme.of(context).colorScheme.secondary
              : Colors.red,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                child: Text(
                  "By: $owner",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),

              Container(
                padding: EdgeInsets.all(8),
                child: Text(
                  formatTime(timeLeft),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.all(8),
            child: Text(
              sessionID,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          SizedBox(height: 5),
          Divider(
            color: Colors.grey,
            thickness: 0.5,
            indent: 20,
            endIndent: 20,
          ),
          SizedBox(height: 5),
          ElevatedButton(
            onPressed: () {print(widget.active.toString() + "                  wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww");},
            style: ElevatedButton.styleFrom(
              backgroundColor: timeLeft > 0
                  ? Theme.of(context).colorScheme.secondary
                  : Colors.grey,
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: Text(
              "Mark Attendance",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 15),
        ],
      ),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 100,
                  width: 400,
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
                //Text(StudentHome.net? "Online" : "Offline",),
                ListTile(
                  title: TextField(
                    decoration: InputDecoration(
                      labelText: "Session ID",
                      hintText: "Enter Session ID",
                    ),
                  ),
                  minLeadingWidth: 0,
                  leading: SizedBox(width: 3),
                  trailing: IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.search_rounded,
                      color: Colors.grey,
                      size: 30,
                    ),
                  ),
                  tileColor: const Color.fromARGB(255, 238, 220, 167),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  "Nearby Sessions",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 20),
                buildSession("SESSION12345", "Dr. Smith"),
                SizedBox(height: 20),
                buildSession("SESSION1232234", "Dr. John"),
                SizedBox(height: 20),
                buildSession("SESSION98765", "Prof. Alice"),
                SizedBox(height: 50),
              ],
            ),
          ),
        ),
    );
  }
}
