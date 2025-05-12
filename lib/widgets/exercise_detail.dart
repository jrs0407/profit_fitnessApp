import 'package:flutter/material.dart';

class ExerciseDetail extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  static const Color primaryPink = Colors.pinkAccent;
  static const Color textLight = Colors.white;
  static const Color textSecondary = Colors.white70;

  const ExerciseDetail({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryPink.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: primaryPink, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            "$label: ",
            style: const TextStyle(color: textSecondary, fontSize: 16),
          ),
          Text(
            value,
            style: const TextStyle(color: textLight, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}