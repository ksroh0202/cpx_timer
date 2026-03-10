import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const CpxTimerApp());
}

class CpxTimerApp extends StatelessWidget {
  const CpxTimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CPX Timer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomePage(),
    );
  }
}
