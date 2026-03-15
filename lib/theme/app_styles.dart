import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppStyles {
  static final cardRadius = BorderRadius.circular(20);
  static final panelRadius = BorderRadius.circular(20);
  static final segmentRadius = BorderRadius.circular(14);
  static final fieldRadius = BorderRadius.circular(14);
  static final pillRadius = BorderRadius.circular(16);
  static final floatingBarRadius = BorderRadius.circular(16);

  static const surfaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.backgroundTop,
      AppColors.backgroundBottom,
    ],
  );

  static BoxDecoration glassPanelDecoration({
    BorderRadius? borderRadius,
    Color? color,
  }) {
    return BoxDecoration(
      color: color ?? AppColors.glassSurface,
      borderRadius: borderRadius ?? panelRadius,
      border: Border.all(color: AppColors.borderLight, width: 1),
      boxShadow: [
        BoxShadow(
          color: AppColors.shadowLight,
          offset: const Offset(-3, -3),
          blurRadius: 12,
        ),
        BoxShadow(
          color: AppColors.shadowDark,
          offset: const Offset(5, 5),
          blurRadius: 14,
        ),
      ],
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          (color ?? AppColors.glassSurface).withValues(alpha: 0.98),
          color ?? AppColors.glassSurface,
        ],
      ),
    );
  }

  static BoxDecoration glassButtonDecoration({
    BorderRadius? borderRadius,
  }) {
    return glassPanelDecoration(
      borderRadius: borderRadius ?? fieldRadius,
      color: AppColors.glassSurfaceSecondary,
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
    color: AppColors.primaryText,
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
    color: AppColors.secondaryText,
  );

  static const labelText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    color: AppColors.secondaryText,
  );

  static const captionText = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: AppColors.secondaryText,
  );

  static const smallText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.secondaryText,
  );
}
