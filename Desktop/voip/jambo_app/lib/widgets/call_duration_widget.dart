import 'package:flutter/material.dart';

class CallDurationWidget extends StatelessWidget {
  final int duration;
  final bool isActive;

  const CallDurationWidget({
    Key? key,
    required this.duration,
    this.isActive = true,
  }) : super(key: key);

  String get formattedDuration {
    final minutes = (duration ~/ 60).toString().padLeft(2, '0');
    final seconds = (duration % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            size: 18,
            color: isActive ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            formattedDuration,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
