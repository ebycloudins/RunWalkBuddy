import 'package:flutter/material.dart';

class TimerCard extends StatelessWidget {
  final bool isRunning;
  final bool isPaused;
  final bool isRunPhase;
  final String formattedTime;

  const TimerCard({
    super.key,
    required this.isRunning,
    required this.isPaused,
    required this.isRunPhase,
    required this.formattedTime,
  });

  @override
  Widget build(BuildContext context) {
    final phaseName = isRunPhase ? 'RUN' : 'WALK';

    final statusText = !isRunning
        ? 'READY'
        : isPaused
            ? 'PAUSED'
            : phaseName;

    final screenHeight = MediaQuery.sizeOf(context).height;

    // Give the timer enough vertical space while
    // keeping the controls below it visible.
    final cardHeight = (screenHeight * 0.30).clamp(240.0, 300.0);

    return SizedBox(
      height: cardHeight,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF0B7778),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: const Color(0xFF2C9697),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // READY / RUN / WALK badge
          Container(
  padding: const EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 7,
  ),
  decoration: BoxDecoration(
    color: const Color(0xFF8FAF3D).withValues(alpha: 0.28),
    borderRadius: BorderRadius.circular(20),
  ),
  child: Text(
    statusText,
    style: const TextStyle(
      color: Color(0xFFD4EC8A),
      fontSize: 12,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.6,
    ),
  ),
),

            const SizedBox(height: 14),

            // Large countdown
            Text(
              formattedTime,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 76,
                fontWeight: FontWeight.w800,
                height: 0.95,
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              !isRunning
                  ? 'Set your intervals and start'
                  : isPaused
                      ? 'Timer paused'
                      : isRunPhase
                          ? 'Time to run!'
                          : 'Time to walk!',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}