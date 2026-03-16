import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radii.dart';
import 'app_shadows.dart';

class AppStyles {
  static final cardRadius = BorderRadius.circular(AppRadii.card);
  static final panelRadius = BorderRadius.circular(AppRadii.panel);
  static final segmentRadius = BorderRadius.circular(AppRadii.pill);
  static final fieldRadius = BorderRadius.circular(AppRadii.field);
  static final pillRadius = BorderRadius.circular(AppRadii.pill);
  static final floatingBarRadius = BorderRadius.circular(24);

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
      boxShadow: AppShadows.glassPanel,
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
    fontSize: 72,
    fontWeight: FontWeight.w500,
    height: 0.92,
    letterSpacing: -2.4,
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
