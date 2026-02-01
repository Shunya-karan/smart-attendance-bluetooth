import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';


class StudentScan extends StatefulWidget {
  const StudentScan({super.key});

  @override
  State<StudentScan> createState() => _StudentScanState();
}

class _StudentScanState extends State<StudentScan> {
  bool isBtOn = false;
  bool dialogShown = false;
  Timer? _timer;
  int remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    initBluetooth();
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
        if (dialogShown) {
  Navigator.of(context, rootNavigator: true).pop();
  dialogShown = false;
}

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
        content: const Text("Please turn ON Bluetooth to continue attendance."),
        actions: [
          TextButton(
            onPressed: () {
              AppSettings.openAppSettings(
                type: AppSettingsType.bluetooth,
              );
            },
            child: const Text("Turn On"),
          ),
        ],
      );
    },
  );
}

  void startTimer(int remainingSeconds) {
  _timer?.cancel();

  _timer = Timer.periodic(
    const Duration(seconds: 1),
    (timer) {
      if (remainingSeconds == 0) {
        timer.cancel();
      } else {
        setState(() {
          remainingSeconds--;
        });
      }
    },
  );
}

  String formatTime(int seconds) {
  final minutes = seconds ~/ 60;
  final secs = seconds % 60;
  return "${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
}



  Widget buildSession(String sessionID, String owner, int remainingSeconds) {
    if (remainingSeconds > 0) {
      startTimer(remainingSeconds);
    } else {
      _timer?.cancel();
    }
    return Container(
      width: 400,
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromARGB(255, 116, 99, 0), width: 1.0),
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
            child: Text("By: $owner", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),),
          ),

          Container(
            padding: EdgeInsets.all(8),
            child:
          Text(formatTime(remainingSeconds),
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.red
            ), ),)
            ]
          ),
          Container(
            padding: EdgeInsets.all(8),
            child: Text(sessionID, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),),
          ),
          SizedBox(height: 5),
          Divider(
            color: Colors.grey,
            thickness: 0.5,
            indent: 20,
            endIndent: 20,
          ),
          SizedBox(height: 5),
          ElevatedButton(onPressed: () {},
           style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
           ),
           child: Text("Mark Attendance",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white
            ),
           )
           ),
           SizedBox(height: 15),

          
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 238, 232),
      body: SafeArea(
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
                    border: Border.all(color: isBtOn? Colors.blueAccent : Colors.redAccent, width: 1.3),
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
              ListTile(
                title: TextField(
                  decoration: InputDecoration(
                    labelText: "Session ID",
                    hintText: "Enter Session ID",
                  ),
                ),
                minLeadingWidth: 0,
                leading: SizedBox(width: 3),
                trailing: IconButton(onPressed: () {},
                 icon: Icon(Icons.search_rounded, color: Colors.grey, size: 30,)),
                 tileColor: const Color.fromARGB(255, 238, 220, 167),
                 shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50)
                 ),
              ),
              SizedBox(height: 30),
              Text("Nearby Sessions",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black
              ),
              ),
              SizedBox(height: 20),
              buildSession("SESSION12345", "Dr. Smith", 120),
              SizedBox(height: 20,),
              buildSession("SESSION1232234", "Dr. John", 300),
              SizedBox(height: 20,),
              buildSession("SESSION98765", "Prof. Alice", 0),
              SizedBox(height: 50),
            ],
          ),
          ) 
        )
        ),
        bottomNavigationBar: Container(
  height: 70,
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: Colors.white,
    boxShadow: [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 8,
        offset: Offset(0, -2),
      ),
    ],
  ),
  child: Center(
    child: ElevatedButton(
      onPressed: isBtOn ? () {} : null,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 160),
        backgroundColor: isBtOn ? Colors.blue : Colors.grey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        "Scan",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    ),
  ),
),

    );
  }
}