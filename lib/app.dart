import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/theme.dart';
import 'providers/settings_provider.dart';
import 'screens/home_screen.dart';

class TaCompanionApp extends ConsumerWidget {
  const TaCompanionApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'TA',
      debugShowCheckedModeBanner: false,
      theme: settings.isDarkMode ? AppTheme.dark : AppTheme.light,
      home: const HomeScreen(),
    );
  }
}
