import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:smart_attendance_bluetooth/student/other_required.dart';
import 'package:smart_attendance_bluetooth/student/ble_scan.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class StudentScan extends StatefulWidget {
  final bool active;
  const StudentScan({super.key, required this.active});

  @override
  State<StudentScan> createState() => _StudentScanState();
}

class _StudentScanState extends State<StudentScan> with WidgetsBindingObserver {
  BleManager bleManager = BleManager();
  StreamSubscription<List<BleSession>>? sessionSub;
  List<BleSession> nearbySessions = [];
  bool isBtOn = false;
  bool started = false;
  bool scanning = false;
  String rollNo = "";

  bool isLocationOn = false;
bool isLocationPermissionGranted = false;


  bool dialogShown = false;

  bool attendanceSent = false;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    initBluetoothUI();
    checkLocationStatus();
    getRoll();

  }

@override
void dispose() {
  sessionSub?.cancel();
sessionSub = null;
bleManager.stopScan();

  WidgetsBinding.instance.removeObserver(this);
  super.dispose();
}


Future<void> startLiveScan() async {
  if (sessionSub != null) return;
  if (!mounted) return;
  if (!isBtOn || !isLocationOn || !isLocationPermissionGranted) return;

  await sessionSub?.cancel();
  nearbySessions.clear();

  sessionSub = bleManager.startSessionScan().listen((sessions) {
    if (!mounted) return;
    setState(() {
      nearbySessions = sessions;
      
    });
  });
}

Future<void> getRoll() async {
  final pref = await SharedPreferences.getInstance();
  final roll = pref.getString("seatNumber");
  if (roll != null) {
    setState(() {
      rollNo = roll;
    });
  }
  }


  void showSnack(String msg) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

Future<void> checkLocationStatus() async {
  final serviceOn = await Permission.location.serviceStatus.isEnabled;
  final permission = await Permission.locationWhenInUse.status;

  if (!mounted) return;

  setState(() {
    isLocationOn = serviceOn;
    isLocationPermissionGranted = permission.isGranted;
  });

  if (isBtOn && isLocationOn && isLocationPermissionGranted) {
    startLiveScan();
  }
}



  void initBluetoothUI() async {
    await AppBluetoothService.requestPermissions();
    final status = await Permission.location.status;
print("Location permission: $status");


    AppBluetoothService.adapterState().listen((state) {
      if (!mounted) return;

      final btOn = state == BluetoothAdapterState.on;

      setState(() => isBtOn = btOn);

    if (!btOn) {
  sessionSub?.cancel();
  bleManager.stopScan();
}


      if (!btOn && !dialogShown) {
        dialogShown = true;
        _showBtDialog();
      }

      if (btOn && dialogShown) {
        Navigator.pop(context);
        dialogShown = false;
      }

 if (btOn && sessionSub == null && isLocationOn && isLocationPermissionGranted) {
  startLiveScan();
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

 Widget buildSession(BleSession session) {
  return Container(
    width: 400,
    decoration: BoxDecoration(
      border: Border.all(
        color: Theme.of(context).colorScheme.secondary,
        width: 1.0,
      ),
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
    ),
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            "By: ${session.owner}",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        Text(
          session.sessionId,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const Divider(thickness: 0.5),
        ElevatedButton(
            onPressed: () async {
    final success = await bleManager.markAttendance(
      session: session,
      studentId: rollNo, // later: real student ID
    );

    showSnack(
      success
          ? "Attendance marked ✅"
          : "Attendance failed ❌",
    );
  },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            "Mark Attendance",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 15),
      ],
    ),
  );
}

Widget locationCard() {
  final allGood = isLocationOn && isLocationPermissionGranted;

  return Container(
    height: 110,
    width: 400,
    decoration: BoxDecoration(
      border: Border.all(
        color: allGood ? Colors.green : Colors.redAccent,
        width: 1.3,
      ),
      borderRadius: BorderRadius.circular(12),
      color: const Color.fromARGB(255, 240, 255, 240),
    ),
    child: Row(
      children: [
        const SizedBox(width: 10),
        Icon(
          allGood
              ? Icons.location_on_outlined
              : Icons.location_off_outlined,
          size: 40,
          color: allGood ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 10),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Location",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              isLocationPermissionGranted
                  ? "Permission: Granted"
                  : "Permission: Required",
              style: TextStyle(
                fontSize: 13,
                color: isLocationPermissionGranted
                    ? Colors.green
                    : Colors.red,
              ),
            ),
            Text(
              isLocationOn ? "Service: ON" : "Service: OFF",
              style: TextStyle(
                fontSize: 13,
                color: isLocationOn ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
        const Spacer(),
        Switch(
          value: allGood,
          onChanged: (_) async {
            if (!isLocationPermissionGranted) {
              await Permission.locationWhenInUse.request();
            } else if (!isLocationOn) {
              AppSettings.openAppSettings(
                type: AppSettingsType.location,
              );
            }
            await checkLocationStatus();
          },
        ),
        const SizedBox(width: 10),
      ],
    ),
  );
}



  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
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
              SizedBox(height: 7),
              locationCard(),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
              Text(
                "Nearby Sessions",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              IconButton(
                onPressed: () {
  if (!isLocationOn || !isLocationPermissionGranted) {
    showSnack("Enable Location to scan sessions");
    return;
  }
  startLiveScan();
},
                icon: Icon(
                  Icons.refresh_rounded,
                  color: Colors.grey,
                  size: 30,
                ),
              ),]),
              SizedBox(height: 20),
              if (nearbySessions.isEmpty)
  const Text(
    'No nearby sessions found',
    style: TextStyle(fontSize: 16, color: Colors.red),
  )
else
  ...nearbySessions.map((session) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: buildSession(session),
    );
  }).toList(),


              SizedBox(height: 50), 
            ],
          ),
        ),
      ),
    );
  }
}