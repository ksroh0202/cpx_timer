import 'package:flutter/material.dart';
import 'screens/home_page.dart';

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
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      home: const HomePage(),
    );
  }
}
