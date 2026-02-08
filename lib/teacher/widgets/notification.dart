import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

class NotificationBox extends StatelessWidget {
  final String message;

  const NotificationBox({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.lightBlue[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications, color: Colors.blueAccent),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: 20, // fix height for marquee
              child: Marquee(
                text: message,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                scrollAxis: Axis.horizontal,
                crossAxisAlignment: CrossAxisAlignment.start,
                blankSpace: 50.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}