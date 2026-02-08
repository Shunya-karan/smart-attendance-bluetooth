import 'package:flutter/services.dart';

class TeacherBleService {
  static const MethodChannel _channel = MethodChannel('teacher_ble');

  static Future<void> startBleSession({
    required String sessionCode,
    required String className,
    required String subjectName,
  }) async {
    await _channel.invokeMethod('startSession', {
      "sessionCode": sessionCode,
      "className": className,
      "subjectName": subjectName,
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
