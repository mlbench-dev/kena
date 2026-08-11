import 'package:flutter/material.dart';

class EmotionProgressBar extends StatelessWidget {
  final String label;
  final double value; // Expected between 0.0 and 1.0
  final Color color;

  const EmotionProgressBar({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
            fontFamily: "Inter",
          ),
        ),
        const SizedBox(height: 8), // Gap between title and bar
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          child: LinearProgressIndicator(
            value: value,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            backgroundColor: Colors.grey[200],
            minHeight: 24, // Matches the chunky look of the screenshot
          ),
        ),
        const SizedBox(height: 20), // Gap between different bars
      ],
    );
  }
}
