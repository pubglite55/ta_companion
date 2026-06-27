import 'package:flutter/material.dart';
import 'config/theme.dart';
import 'screens/home_screen.dart';

class TaCompanionApp extends StatelessWidget {
  const TaCompanionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const HomeScreen(),
    );
  }
}
