import 'package:flutter/material.dart';

class CustomStepper extends StatelessWidget {
  final String label;
  final int value;
  final Function(int) onChanged;

  const CustomStepper({
    Key? key,
    required this.label,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1C),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '$label: $value',
                style: const TextStyle(color: Colors.white)
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () => onChanged(value > 0 ? value - 1 : 0),
                  icon: const Icon(
                    Icons.remove_circle_outline,
                    color: Color(0xFF0DCAF0)
                  ),
                ),
                IconButton(
                  onPressed: () => onChanged(value + 1),
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: Color(0xFF0DCAF0)
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