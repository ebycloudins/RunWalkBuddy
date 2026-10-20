import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  final Widget next;

  const SplashScreen({
    super.key,
    required this.next,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..forward();

  late final AnimationController _dots = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  late final Animation<double> _fade =
      CurvedAnimation(
        parent: _intro,
        curve: Curves.easeOut,
      );

  late final Animation<double> _scale =
      Tween<double>(
        begin: 0.85,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: _intro,
          curve: Curves.easeOutBack,
        ),
      );

  @override
  void initState() {
    super.initState();

    Future.delayed(
      const Duration(milliseconds: 2600),
      () {
        if (!mounted) return;

        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration:
                const Duration(milliseconds: 400),
            pageBuilder: (_, __, ___) => widget.next,
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _intro.dispose();
    _dots.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.background,
        ),
        child: SafeArea(
          child: Stack(
            alignment: Alignment.center,
            children: [
              FadeTransition(
                opacity: _fade,
                child: ScaleTransition(
                  scale: _scale,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      SizedBox(
                        width: 130,
                        height: 130,
                        child: CustomPaint(
                          painter: LogoPainter(),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'RUNWALK',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 3,
                          height: 1,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'BUDDY',
                        style: TextStyle(
                          color: Color(0xFFB9F14E),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 7,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Your Run-Walk Training Partner',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Positioned(
                bottom: 40,
                child: AnimatedBuilder(
                  animation: _dots,
                  builder: (_, __) {
                    final active = (_dots.value * 3).floor();

                    return Row(
                      children: List.generate(
                        3,
                        (i) {
                          final on = i == active;

                          return Container(
                            width: 7,
                            height: 7,
                            margin:
                                const EdgeInsets.symmetric(
                              horizontal: 3.5,
                            ),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: on
                                  ? const Color(0xFFB9F14E)
                                  : Colors.white24,
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LogoPainter extends CustomPainter {
  const LogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 100);

    const circumference = 251.3;

    double arc(double len) {
      return len / circumference * 2 * math.pi;
    }

    const start = -math.pi / 2;

    final rect = Rect.fromCircle(
      center: const Offset(50, 50),
      radius: 40,
    );

    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      start,
      arc(165),
      false,
      ring..color = const Color(0xFFB9F14E),
    );

    canvas.drawArc(
      rect,
      start + arc(180),
      arc(55),
      false,
      ring..color = Colors.white70,
    );

    final body = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = Colors.white;

    canvas.drawCircle(
      const Offset(55, 32),
      5,
      Paint()..color = Colors.white,
    );

    final path = Path()
      ..moveTo(52, 40)
      ..lineTo(47, 56)
      ..moveTo(50, 44)
      ..lineTo(58, 49)
      ..moveTo(50, 44)
      ..lineTo(42, 48)
      ..moveTo(47, 56)
      ..lineTo(56, 60)
      ..lineTo(55, 69)
      ..moveTo(47, 56)
      ..lineTo(40, 63)
      ..lineTo(33, 61);

    canvas.drawPath(path, body);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}