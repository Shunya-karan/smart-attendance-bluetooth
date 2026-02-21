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
  final VoidCallback onBack;

  const StudentScan({super.key, required this.active, required this.onBack});

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

  String rollNo = "";

  bool userInitiatedCheck = false;

  bool readyToScan() => isBtOn && isLocationOn && isLocationPermissionGranted;

  TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  Set<String> markedSessions = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    initBluetoothUI();
    checkLocationStatus();
    getRoll();

    searchController.addListener(() {
      setState(() {
        searchQuery = searchController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    sessionSub?.cancel();
    sessionSub = null;
    searchController.dispose();

    bleManager.stopScan();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      await checkLocationStatus();
    }
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      sessionSub?.cancel();
      bleManager.stopScan();
    }
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
    final roll = pref.getString("studentId");

    if (roll != null) {
      setState(() {
        rollNo = roll;
      });
    }
  }

  void showSnack(String msg, {Color? color}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: TextStyle(
            color: color ?? Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<void> checkLocationStatus() async {
    final serviceOn = await Permission.location.serviceStatus.isEnabled;
    final permission = await Permission.locationWhenInUse.status;

    setState(() {
      isLocationOn = serviceOn;
      isLocationPermissionGranted = permission.isGranted;
    });
  }

  void initBluetoothUI() {
    AppBluetoothService.adapterState().listen((state) {
      if (!mounted) return;

      final btOn = state == BluetoothAdapterState.on;

      setState(() {
        isBtOn = btOn;
      });

      if (!isBtOn) {
        sessionSub?.cancel();
        bleManager.stopScan();
      }
    });
  }

  String format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  Future<void> saveOfflineSession(String session) async {
    final prefs = await SharedPreferences.getInstance();

    final List<String> sessions = prefs.getStringList("offline_sessions") ?? [];

    if (!sessions.contains(session)) {
      sessions.add(session);
      await prefs.setStringList("offline_sessions", sessions);
    }
  }

  Widget _buildStatusBadge(bool expired, bool marked, DateTime endTime) {
    if (marked) {
      return _badge("Marked", Colors.green);
    }

    if (expired) {
      return _badge("Expired", Colors.red);
    }

    return StreamBuilder<int>(
      key: ValueKey(endTime),
      stream: Stream.periodic(const Duration(seconds: 1), (i) => i),
      builder: (_, __) {
        final remaining = endTime.difference(DateTime.now());
        return _badge(
          remaining.inSeconds <= 0 ? "Expired" : format(remaining),
          Colors.red,
        );
      },
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget buildSession(BleSession session) {
    final alreadyMarked = markedSessions.contains(session.sessionId);

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
                child: _buildStatusBadge(expired, alreadyMarked, endTime),
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
              onPressed: expired || alreadyMarked
                  ? null
                  : () async {
                      if (rollNo.isEmpty) {
                        showSnack("Roll number not found. Please login again.");
                        return;
                      }

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

                        setState(() {
                          markedSessions.add(session.sessionId);
                        });

                        final now = DateTime.now();
                        final hour12 = now.hour % 12 == 0 ? 12 : now.hour % 12;
                        final period = now.hour >= 12 ? "PM" : "AM";
                        final time =
                            "${hour12.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} $period";

                        await saveOfflineSession(
                          "${session.sessionId} | $time",
                        );
                        showSnack("Attendance saved locally offline.");
                      }
                    },

              style: ElevatedButton.styleFrom(
                backgroundColor: expired || alreadyMarked
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
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;

    double h = screenwidth < 405 ? 110 : 70;

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
                    horizontal: 1,
                    vertical: 1,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: widget.onBack,
                        icon: const Icon(Icons.arrow_back_ios_new),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Scan Sessions",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                //
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: h,
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
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
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
                                if (screenwidth < 405)
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
                            if (screenwidth > 405)
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
                        height: h,
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
                                SizedBox(height: 1),
                                if (screenwidth < 405)
                                  Transform.scale(
                                    scale: 0.8,
                                    child: Switch(
                                      value:
                                          isLocationOn &&
                                          isLocationPermissionGranted,
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
                            if (screenwidth > 405)
                              Transform.scale(
                                scale: 0.8,
                                child: Switch(
                                  value:
                                      isLocationOn &&
                                      isLocationPermissionGranted,
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
                      hintText: "Search Sessions...",
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
                      onPressed: () async {
                        if (!isBtOn)
                          {showSnack(
                            "Please turn ON Bluetooth . . . ! ! ",
                            color: Colors.red,
                          );}
                        if (!isLocationOn || !isLocationPermissionGranted) {
                          showSnack(
                            "Turn ON Location / Grant Permission . . . ! ! ",
                            color: Colors.red,
                          );
                        }

                        if (!readyToScan()) {
                          return;
                        }
                        ;
                        print("-----------------------------------------------------------------------------------------------------------------------"+rollNo);
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
                        Text(
                          isBtOn && isLocationOn && isLocationPermissionGranted
                              ? 'No nearby sessions found...'
                              : 'Turn ON Bluetooth and Location to scan.',
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
