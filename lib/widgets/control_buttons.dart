import 'package:flutter/material.dart';

class ControlButtons extends StatelessWidget {
  final bool isRunning;
  final bool isPaused;
  final VoidCallback onStartPause;
  final VoidCallback onStop;

  const ControlButtons({
    super.key,
    required this.isRunning,
    required this.isPaused,
    required this.onStartPause,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = isRunning && !isPaused;

    return Row(
      children: [
        // Primary action
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: onStartPause,
            icon: Icon(
              isActive
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              size: 22,
            ),
            label: Text(
              isRunning
                  ? isPaused
                      ? 'Resume'
                      : 'Pause'
                  : 'Start',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF075C60),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 17),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Secondary action
        Expanded(
          flex: 1,
          child: OutlinedButton.icon(
            onPressed: onStop,
            icon: const Icon(
              Icons.stop_rounded,
              size: 20,
            ),
            label: const Text('Stop'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(
                color: Color(0xFF2C9697),
                width: 1,
              ),
              backgroundColor: const Color(0xFF0B7778),
              padding: const EdgeInsets.symmetric(vertical: 17),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}