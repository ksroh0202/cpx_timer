import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppStyles {
  static final cardRadius = BorderRadius.circular(28);
  static final cardInnerRadius = BorderRadius.circular(24);
  static final pillRadius = BorderRadius.circular(999);

  static final cardDecoration = BoxDecoration(
    color: AppColors.surface,
    borderRadius: cardRadius,
  );

  static final softPillDecoration = BoxDecoration(
    color: AppColors.surfaceSoft,
    borderRadius: pillRadius,
  );


  static const headerGradient = LinearGradient(
    colors: [AppColors.surfaceTint, AppColors.background],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static final primaryPillDecoration = BoxDecoration(
    gradient: const LinearGradient(
      colors: [AppColors.primary, AppColors.primaryDark],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
    borderRadius: pillRadius,
  );

  static const timerText = TextStyle(
    fontSize: 50,
    fontWeight: FontWeight.w500,
    letterSpacing: -1,
    color: AppColors.textPrimary,
  );

  static const buttonText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
  );

  static const labelText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static const smallText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

}
