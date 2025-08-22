import 'package:flutter/material.dart';
import '../../theme/ayanna_theme.dart';

class DashboardCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const DashboardCard({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color ?? AyannaColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: AyannaColors.orange, size: 32),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AyannaColors.darkGrey,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AyannaColors.orange,
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
