import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:app_settings/app_settings.dart';


class BluetoothStatusCard extends StatefulWidget {
  final Function(bool scanReady)? onStatusChanged;

  const BluetoothStatusCard({super.key,
  this.onStatusChanged});

  @override
  State<BluetoothStatusCard> createState() => _BluetoothStatusCardState();
}

class _BluetoothStatusCardState extends State<BluetoothStatusCard> {
  bool bluetoothOn = false;
  bool locationGranted = false;
  bool locationServices=false;

  @override
  void initState() {
    super.initState();
    _askAllPermissions();
    _loadStatus();
  }

  Future<void> _askAllPermissions() async {
    await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.locationWhenInUse,
    ].request();
  }

  void _notifyParent() {
    final scanReady = bluetoothOn && locationGranted && locationServices;
    widget.onStatusChanged?.call(scanReady);
  }


  Future<void> _loadStatus() async {
    final btState = await FlutterBluePlus.adapterState.first;
    final loc = await Permission.locationWhenInUse.status;
    final serviceEnabled =await Geolocator.isLocationServiceEnabled();
    setState(() {
      bluetoothOn = btState == BluetoothAdapterState.on;
      locationGranted = loc.isGranted;
      locationServices=serviceEnabled;
    });
    _notifyParent();
  }

  Future<void> _toggleBluetooth(bool value) async {
    if (value) {
      await FlutterBluePlus.turnOn();
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Bluetooth OFF"),
          content: const Text(
            "For security reasons, Bluetooth cannot be turned off directly from the app.\n\nPlease turn it off from Settings.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                AppSettings.openAppSettings(
                  type: AppSettingsType.bluetooth,
                );
              },
              child: const Text("Open Settings"),
            ),
          ],
        ),
      );
    }

    await _loadStatus();
  }



  Future<void> ensureLocationServiceOn() async {
    bool enabled = await Geolocator.isLocationServiceEnabled();

    if (!enabled) {
      await Geolocator.openLocationSettings();
    }
    enabled=await Geolocator.isLocationServiceEnabled();
    setState(() {
      locationServices=enabled;
    });
  }
  Future<void> _requestLocation() async {
    var status = await Permission.locationWhenInUse.status;

    if (status.isPermanentlyDenied) {
      openAppSettings();
      return;
    }

    final result = await Permission.locationWhenInUse.request();

    setState(() {
      locationGranted = result.isGranted;
    });
  }





  @override
  Widget build(BuildContext context) {
    final scanReady = bluetoothOn && locationGranted && locationServices;

    return Container(
      padding:  EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: scanReady ? Colors.green : Colors.red,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bluetooth Switch
          Row(
            children: [
               Icon(Icons.settings_bluetooth, size: 20),
               SizedBox(width: 10),
               Expanded(
                child: Text(
                  "Bluetooth",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
              Text(bluetoothOn ? "ON" : "OFF",
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: bluetoothOn ? Colors.green : Colors.red)),

              Switch(
                value: bluetoothOn,
                onChanged: _toggleBluetooth,
              ),
            ],
          ),

          // Location Button
          Row(
            children: [
               Icon(Icons.location_on, size: 20),
               SizedBox(width: 10),
               Expanded(
                child: Text(
                  "Location Permission",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
              Text(locationGranted ? "GRANTED" : "DENIED",
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: locationGranted ? Colors.green : Colors.red)),
               SizedBox(width: 8),
              ElevatedButton(
                onPressed: locationGranted ? null : _requestLocation,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding:
                   EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: Text(locationGranted ? "Done" : "Allow"),
              ),
            ],
          ),
          Row(
              children: [
                Icon(Icons.location_pin),
                SizedBox(width: 8,),
                Expanded(
                  child: Text("Location Services",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
                ElevatedButton(onPressed:locationServices?null:ensureLocationServiceOn,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(10)
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 10,vertical: 8),
                    ),
                    child: Text(locationServices?"ON️":"Turn ON",
                    style: TextStyle(
                    color: locationServices
                            ?Colors.green
                            :Colors.red)
                ),)

              ],
          ),

           SizedBox(height: 6),
           Text(
            scanReady?
            "Ready to scan nearby student devices"
            :"Required for scanning nearby student devices.",
            style: TextStyle(fontSize: 11,
                color: scanReady
                    ?Colors.green
                    :Colors.red
            ),
          ),
        ],
      ),
    );
  }
}
