import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppStyles {
  static final cardRadius = BorderRadius.circular(28);
  static final panelRadius = BorderRadius.circular(28);
  static final segmentRadius = BorderRadius.circular(24);
  static final fieldRadius = BorderRadius.circular(22);
  static final pillRadius = BorderRadius.circular(999);
  static final floatingBarRadius = BorderRadius.circular(30);

  static const surfaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.backgroundTop,
      AppColors.backgroundBottom,
    ],
  );

  static LinearGradient get glassGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.glassHighlight,
          AppColors.glassPanel,
        ],
      );

  static LinearGradient get glassGradientStrong => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.glassHighlight,
          AppColors.glassPanelStrong,
        ],
      );

  static BoxDecoration glassDecoration({
    BorderRadius? borderRadius,
    bool strong = false,
    bool selected = false,
  }) {
    return BoxDecoration(
      gradient: selected
          ? glassGradientStrong
          : strong
              ? glassGradientStrong
              : glassGradient,
      borderRadius: borderRadius ?? panelRadius,
      border: Border.all(
        color: selected ? AppColors.glassStrokeStrong : AppColors.glassStroke,
      ),
      boxShadow: [
        BoxShadow(
          color: strong ? AppColors.shadowSoft : AppColors.shadowFaint,
          blurRadius: strong ? 28 : 18,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  static BoxDecoration innerGlassDecoration({
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      color: AppColors.glassPanelSoft,
      borderRadius: borderRadius ?? fieldRadius,
      border: Border.all(color: AppColors.glassStroke),
    );
  }

  static final inputBorder = OutlineInputBorder(
    borderRadius: fieldRadius,
    borderSide: BorderSide.none,
  );

  static const timerText = TextStyle(
    fontSize: 68,
    fontWeight: FontWeight.w600,
    height: 0.92,
    letterSpacing: -3.2,
    color: AppColors.textPrimary,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const buttonText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  );

  static const statusText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: AppColors.textSecondary,
  );

  static const labelText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    color: AppColors.textMuted,
  );

  static const captionText = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: AppColors.textMuted,
  );

  static const smallText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );
}
