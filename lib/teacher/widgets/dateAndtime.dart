import 'dart:async';
import 'package:flutter/material.dart';

class DateandTime extends StatefulWidget {


  const DateandTime({
    super.key,});

  @override
  State<DateandTime> createState() => _DateandTimeState();
}

class _DateandTimeState extends State<DateandTime> {
  String currentTime = "";
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _updateTime();
    timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      currentTime =
      "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year} "
          " ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child:Text("${currentTime}",
      style: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 15
      ),) ,
    );
  }
}
