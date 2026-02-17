import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:smart_attendance_bluetooth/student/other_required.dart';
import 'package:smart_attendance_bluetooth/student/ble_scan.dart';

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
  bool isLocationOn = false;
  bool isLocationPermissionGranted = false;
  bool dialogShown = false;
  bool attendanceSent = false;

  String rollNo = "";

  bool userInitiatedCheck = false;

  TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    initBluetoothUI();
    checkLocationStatus();
    getRoll();
    startGlobalTicker();

    searchController.addListener(() {
      setState(() {
        searchQuery = searchController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    sessionSub?.cancel();
    sessionSub = null;

    bleManager.stopScan();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      sessionSub?.cancel();
      bleManager.stopScan();
    }
  }

  void startGlobalTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> startLiveScan() async {
  // 🔑 allow re-scan
  await sessionSub?.cancel();
  sessionSub = null;

  if (scanning) return;

  if (!isBtOn || !isLocationOn || !isLocationPermissionGranted) {
    setState(() => scanning = false);
    return;
  }

  setState(() => scanning = true);

  nearbySessions.clear();

  sessionSub = bleManager.startSessionScan().listen(
    (sessions) {
      if (!mounted) return;
      setState(() {
        nearbySessions = sessions;
      });
    },
    onDone: () {
      // 🔑 VERY IMPORTANT
      if (!mounted) return;
      setState(() {
        scanning = false;
        sessionSub = null;
      });
    },
    onError: (e) {
      if (!mounted) return;
      setState(() {
        scanning = false;
        sessionSub = null;
      });
    },
  );
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

    setState(() {
      isLocationOn = serviceOn;
      isLocationPermissionGranted = permission.isGranted;
    });

    if (userInitiatedCheck) {
      if (!isLocationPermissionGranted) {
        showSnack("Location permission required");
      } else if (!isLocationOn) {
        showSnack("Please turn ON Location");
      }
    }
  }

  void initBluetoothUI() {
    AppBluetoothService.adapterState().listen((state) {
      if (!mounted) return;

      final btOn = state == BluetoothAdapterState.on;

      setState(() {
        isBtOn = btOn;
      });

      if (!btOn) {
        sessionSub?.cancel();
        bleManager.stopScan();

        if (userInitiatedCheck) {
          showSnack("Please turn ON Bluetooth");
        }
      }
    });
  }

  String format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$m:$s";
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

  Widget _buildStatusBadge(bool expired, dynamic remaining) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        expired ? "Expired" : format(remaining),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.red[700],
        ),
      ),
    );
  }

  Widget buildSession(BleSession session) {
    final parts = session.sessionId.split('-');
    if (parts.length != 4) return const SizedBox();

    final c = parts[0];
    final s = parts[1];
    final time = parts[3];

    final h = int.tryParse(time.substring(0, 2));
    final m = int.tryParse(time.substring(2, 4));
    if (h == null || m == null) return const SizedBox();

    final now = DateTime.now();
    final endTime = DateTime(now.year, now.month, now.day, h, m);
    final remaining = endTime.difference(now);
    final expired = remaining.inSeconds <= 0;

    return Container(
      width: double.infinity,
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
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  "Subject: $s",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(8),
                child: _buildStatusBadge(expired, remaining),
              ),
            ],
          ),
          Text(
            c,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Divider(thickness: 1, indent: 20, endIndent: 20),
          Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton(
              onPressed: expired || attendanceSent
                  ? null
                  : () async {
                      if (rollNo.isEmpty) {
                        showSnack("Roll number not found. Please login again.");
                        return;
                      }

                      setState(() {
                        attendanceSent = true;
                      });

                      final success = await bleManager.markAttendance(
                        session: session,
                        studentId: rollNo,
                      );

                      showSnack(
                        success ? "Attendance marked ✅" : "Attendance failed ❌",
                      );

                      if (success) {
                        await sessionSub?.cancel();
                        sessionSub = null;
                        bleManager.stopScan();
                      }

                      if (!success) {
                        setState(() {
                          attendanceSent = false;
                        });
                      }
                    },

              style: ElevatedButton.styleFrom(
                backgroundColor: expired || attendanceSent
                    ? Colors.grey
                    : Theme.of(context).colorScheme.secondary,

                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 20,
                ),
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
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredSessions = searchQuery.isEmpty
        ? nearbySessions
        : nearbySessions.where((session) {
            return session.sessionId.toLowerCase().contains(
              searchQuery.toLowerCase(),
            );
          }).toList();
    return SafeArea(
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Scan Sessions",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                //
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 70,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isBtOn
                                ? Colors.blueAccent
                                : Colors.redAccent,
                            width: 1.3,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: const Color.fromARGB(255, 236, 250, 255),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isBtOn
                                      ? Icons.bluetooth_rounded
                                      : Icons.bluetooth_disabled_rounded,
                                  size: 28,
                                  color: isBtOn ? Colors.blue : Colors.red,
                                ),
                                const SizedBox(width: 5),
                                const Text(
                                  "Bluetooth",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Transform.scale(
                              scale: 0.8,
                              child: Switch(
                                value: isBtOn,
                                onChanged: (val) {
                                  AppSettings.openAppSettings(
                                    type: AppSettingsType.bluetooth,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 5), // spacing between cards
                    Expanded(
                      child: Container(
                        height: 70,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isLocationOn && isLocationPermissionGranted
                                ? Colors.green
                                : Colors.redAccent,
                            width: 1.3,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: const Color.fromARGB(255, 240, 255, 240),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      isLocationOn &&
                                              isLocationPermissionGranted
                                          ? Icons.location_on_outlined
                                          : Icons.location_off_outlined,
                                      size: 25,
                                      color:
                                          isLocationOn &&
                                              isLocationPermissionGranted
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                    const SizedBox(width: 5),
                                    const Text(
                                      "Location",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  isLocationPermissionGranted
                                      ? "Permission: Granted"
                                      : "Permission: Required",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isLocationPermissionGranted
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                                Text(
                                  isLocationOn ? "Service: ON" : "Service: OFF",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isLocationOn
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            Transform.scale(
                              scale: 0.8,
                              child: Switch(
                                value:
                                    isLocationOn && isLocationPermissionGranted,
                                onChanged: (_) async {
                                  if (!isLocationPermissionGranted) {
                                    await Permission.locationWhenInUse
                                        .request();
                                  } else if (!isLocationOn) {
                                    AppSettings.openAppSettings(
                                      type: AppSettingsType.location,
                                    );
                                  }
                                  await checkLocationStatus();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // locationCard(),
                SizedBox(height: 20),
                //Text(StudentHome.net? "Online" : "Offline",),
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: TextField(
                    controller: searchController,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      hintText: "Enter Session ID",
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: Colors.grey,
                      ),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                searchController.clear();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
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
                      onPressed: scanning
                          ? null
                          : () async {
                        userInitiatedCheck = true;

                        await checkLocationStatus();

                        if (!isBtOn) return;
                        if (!isLocationOn || !isLocationPermissionGranted) {
                        userInitiatedCheck = false;

                        return;
                        };

                        startLiveScan();
                      },

                      icon: Icon(
                        Icons.refresh_rounded,
                        color: Colors.grey,
                        size: 30,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                ...(filteredSessions.isEmpty
                    ? [
                        const Text(
                          'No nearby sessions found',
                          style: TextStyle(fontSize: 16, color: Colors.red),
                        ),
                      ]
                    : filteredSessions
                          .map(
                            (session) => Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: buildSession(session),
                            ),
                          )
                          .toList()),

                SizedBox(height: 600),
              ],
            ),
          ),
          Positioned(
            bottom:
      16,
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
                    onPressed: scanning
                        ? null
                        : () async {
                      userInitiatedCheck = true;

                      await checkLocationStatus();

                      if (!isBtOn) return;
                      if (!isLocationOn || !isLocationPermissionGranted) {
                        userInitiatedCheck = false;

                        return;
                        };

                      startLiveScan();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      scanning ? "Scanning..." : "Scan Session",

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
