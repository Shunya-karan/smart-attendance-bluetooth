import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'dart:async';

class AppBluetoothService {
  static Future<void> requestPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
    ].request();
  }

  static Stream<BluetoothAdapterState> adapterState() {
    return FlutterBluePlus.adapterState;
  }
}

class NetworkListener {
  StreamSubscription? _sub;

  void start(void Function(bool isOnline) onChanged) {
    _sub = Connectivity().onConnectivityChanged.listen((_) async {
      final hasInternet =
          await InternetConnectionChecker().hasConnection;
      onChanged(hasInternet);
    });
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
  }
}


