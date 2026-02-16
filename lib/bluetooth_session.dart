import 'package:flutter/services.dart';

class TeacherBleService {
  static const MethodChannel _channel = MethodChannel('teacher_ble');

  static Future<void> startBleSession({
    required String sessionCode,
  }) async {
    await _channel.invokeMethod('startSession', {
      "sessionCode": sessionCode,
    });
  }

  static Future<void> stopBleSession() async {
    await _channel.invokeMethod('stopSession');
  }

  static void listenAttendance(void Function(String roll) onMarked) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == "attendanceMarked") {
        onMarked(call.arguments as String);
      }
    });
  }
}
