import 'package:flutter/material.dart';

class AppColors {
  static const transparent = Colors.transparent;

  static const background = Color(0xFFCFD9DF);
  static const backgroundTop = Color(0xFFCFD9DF);
  static const backgroundBottom = Color(0xFFE2EBF0);

  static const blobPrimary = Color(0xFFA1C4FD);
  static const blobSecondary = Color(0xFFC2E9FB);

  static const glassSurface = Color(0x47FFFFFF);
  static const glassSurfaceSecondary = Color(0x3DFFFFFF);

  static const primaryText = Color(0xFF1F2A37);
  static const secondaryText = Color(0xFF5D6B7B);
  static const accent = Color(0xFF2563EB);

  static final borderLight = Colors.white.withValues(alpha: 0.42);
  static final shadowDark = const Color(0xFF6B7280).withValues(alpha: 0.16);
  static final shadowLight = Colors.white.withValues(alpha: 0.55);

  static const surface = glassSurface;
  static const surfaceSoft = glassSurfaceSecondary;
  static const accentSoft = secondaryText;
  static const accentMuted = secondaryText;
  static const primaryTextOn = glassSurface;
  static const textPrimary = primaryText;
  static const textSecondary = secondaryText;
  static const textMuted = secondaryText;
  static const divider = Color(0x10FFFFFF);
  static const dividerDark = Color(0x12222222);
  static const progressTrack = Color(0x14FFFFFF);
  static const progressValue = primaryText;
  static const iconSoft = secondaryText;
}
