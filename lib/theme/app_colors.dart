import 'package:flutter/material.dart';

class AppColors {
  // Background
  static const bgTop = Color(0xFF129A99);
  static const bgBottom = Color(0xFF085C62);

  // Accents
  static const run = Color(0xFFD4EC8A);
  static const walk = Color(0xFF7FE6F5);

  // Text
  static const text = Color(0xFFFFFFFF);
  static const muted = Color(0xFFCDEBEA);

  // Buttons
  static const button = Color(0xFFFFFFFF);
  static const onButton = Color(0xFF0A5F66);

  // Bottom sheet / dialogs
  static const sheet = Color(0xFF0A5358);

  // Translucent UI
  static const card = Color(0x22FFFFFF);
  static const border = Color(0x3AFFFFFF);
  static const ringTrack = Color(0x30FFFFFF);
  static const arrowBtn = Color(0x29FFFFFF);

  // Accent backgrounds
  static const runTint = Color(0x33D4EC8A);
  static const walkTint = Color(0x387FE6F5);

  // Active card glow
  static const activeGlow = Color(0x59D4EC8A);

  // Background gradient
  static const background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      bgTop,
      bgBottom,
    ],
  );
}