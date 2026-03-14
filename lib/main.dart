import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import 'theme/app_theme.dart';

// 앱 실행이 시작되는 가장 첫 진입점입니다.
void main() {
  runApp(const CpxTimerApp());
}

// 앱 전체 설정을 감싸는 최상위 위젯입니다.
class CpxTimerApp extends StatelessWidget {
  const CpxTimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp은 앱의 기본 구조, 테마, 첫 화면을 정합니다.
    return MaterialApp(
      title: 'CPX Timer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomePage(),
    );
  }
}
