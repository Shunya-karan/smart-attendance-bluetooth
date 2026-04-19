import 'package:flutter/material.dart';

class StatsCard extends StatelessWidget {
  final String heading;
  final String totalCount;
  final Color cardColor;
  final IconData statsIcons;

  const StatsCard({
    super.key,
    required this.cardColor,
    required this.heading,
    required this.totalCount,
    required this.statsIcons,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: cardColor,
      // elevation: 20,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        width: 130,
        height: 150,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              heading,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(statsIcons, color: Colors.white, size: 30),
                const SizedBox(width: 20),
                Text(
                  totalCount,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
