import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppShadows {
  static final List<BoxShadow> glassPanel = [
    BoxShadow(
      color: AppColors.shadowLight,
      offset: const Offset(-2, -2),
      blurRadius: 10,
      spreadRadius: 0.2,
    ),
    BoxShadow(
      color: AppColors.shadowDark,
      offset: const Offset(7, 10),
      blurRadius: 20,
      spreadRadius: -4,
    ),
  ];

  const AppShadows._();
}
