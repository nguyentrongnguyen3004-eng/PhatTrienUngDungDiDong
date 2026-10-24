import 'package:flutter/material.dart';
import 'screens/bai_tap_02_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 10 - Bài tập 02 (SQL Server API)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF512DA8)),
        useMaterial3: true,
      ),
      home: const BaiTap02Screen(),
    );
  }
}
