import 'package:flutter/material.dart';

class SensorCard extends StatelessWidget {
  final String label;
  final String value;
  final double? progress;
  final Color color;
  final IconData? icon;
  final bool? isOn;
  final VoidCallback? onPressed;

  const SensorCard({
    super.key,
    required this.label,
    required this.value,
    this.progress,
    required this.color,
    this.icon,
    this.isOn,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              Icon(icon,
                  size: 32,
                  color: isOn != null
                      ? (isOn! ? Colors.green : Colors.grey)
                      : color),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isOn != null
                        ? (isOn! ? Colors.green : Colors.grey)
                        : color)),
            if (progress != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress!.clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                      progress! > 0.3 ? Colors.green : Colors.red),
                ),
              ),
            ],
            if (onPressed != null) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: onPressed,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isOn != null
                        ? (isOn! ? Colors.green : Colors.white)
                        : color,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: isOn != null
                            ? (isOn! ? Colors.green : Colors.grey)
                            : color,
                        width: 2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                          isOn != null
                              ? Icons.eco
                              : icon,
                          color: isOn != null
                              ? (isOn! ? Colors.white : Colors.green)
                              : Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        isOn != null ? (isOn! ? "ON" : "OFF") : "Status",
                        style: TextStyle(
                            color: isOn != null
                                ? (isOn! ? Colors.white : Colors.green)
                                : Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
