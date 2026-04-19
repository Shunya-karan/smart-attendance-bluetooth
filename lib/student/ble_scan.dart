import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

final Guid BLE_SERVICE_UUID = Guid("df3dca32-611e-4130-ad8c-df64d8d867c9");

final Guid BLE_CHAR_UUID = Guid("52912853-4e88-42e0-a12b-abdcffc7ebd5");

class BleSession {
  final String sessionId;
  final String owner;
  final ScanResult scanResult;

  BleSession({
    required this.sessionId,
    required this.owner,
    required this.scanResult,
  });
}

class BleManager {
  StreamSubscription<List<ScanResult>>? _scanSub;
  final Map<String, BleSession> _sessions = {};

  final StreamController<List<BleSession>> _sessionController =
      StreamController.broadcast();

  bool _isScanning = false;

  Stream<List<BleSession>> startSessionScan() {
    _startScan();
    return _sessionController.stream;
  }

  Future<void> _startScan() async {
    if (_isScanning) return;
    _isScanning = true;

    await stopScan();
    await Future.delayed(const Duration(milliseconds: 600));

    await FlutterBluePlus.startScan(
      androidUsesFineLocation: true,
    );

    _scanSub = FlutterBluePlus.scanResults.listen((results) {
      for (final r in results) {

        final raw = r.advertisementData.manufacturerData[0x1234];
        if (raw == null || raw.isEmpty) continue;

        final sessionCode = String.fromCharCodes(Uint8List.fromList(raw));

        final deviceId = r.device.remoteId.str;

        _sessions[deviceId] = BleSession(
          sessionId: sessionCode,
          owner: "TEACHER",
          scanResult: r,
        );
      }

      _sessionController.add(_sessions.values.toList());
    });
  }

  Future<void> stopScan() async {
    _isScanning = false;

    await _scanSub?.cancel();
    _scanSub = null;

    await FlutterBluePlus.stopScan();
  }

  // Future<bool> markAttendance({
  //   required BleSession session,
  //   required String studentId,
  // }) async {
  //   final device = session.scanResult.device;
  //
  //   try {
  //     await stopScan();
  //
  //     // connect ONCE
  //     await device.connect(
  //       timeout: const Duration(seconds: 10),
  //       autoConnect: false,
  //     );
  //
  //     await Future.delayed(const Duration(milliseconds: 300));
  //
  //     final services = await device.discoverServices();
  //
  //     for (final s in services) {
  //       if (s.uuid == BLE_SERVICE_UUID) {
  //         for (final c in s.characteristics) {
  //           if (c.uuid == BLE_CHAR_UUID) {
  //
  //             // send studentId
  //             await c.write(
  //               studentId.codeUnits,
  //               withoutResponse: false,
  //             );
  //
  //             return true; // success immediately after write
  //           }
  //         }
  //       }
  //     }

  //     return false;
  //   } catch (e) {
  //     print("WRITE ERROR: $e");
  //     return false;
  //   } finally {
  //     try {
  //       await device.disconnect();
  //     } catch (_) {}
  //   }
  // }

  Future<bool> markAttendance({
    required BleSession session,
    required String studentId,
  }) async {
    final device = session.scanResult.device;

    try {
      // 🔴 DO NOT stop scan yet
      // stopping scan too early causes timeout

      await device.connect(
        timeout: const Duration(seconds: 12),
        autoConnect: false,
      );

      await Future.delayed(const Duration(milliseconds: 400));

      // now stop scan
      await stopScan();

      final services = await device.discoverServices();

      for (final s in services) {
        if (s.uuid == BLE_SERVICE_UUID) {
          for (final c in s.characteristics) {
            if (c.uuid == BLE_CHAR_UUID) {

              await c.write(
                studentId.codeUnits,
                withoutResponse: false,
              );

              return true;
            }
          }
        }
      }

      return false;
    } catch (e) {
      print("WRITE ERROR: $e");
      return false;
    } finally {
      try {
        await Future.delayed(const Duration(milliseconds: 300));
        await device.disconnect();
      } catch (_) {}
    }
  }

  void dispose() {
    stopScan();
    _sessionController.close();
  }

  
}
