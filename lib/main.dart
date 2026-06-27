import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Hive.initFlutter();
    await Hive.openBox('settings');
    await Hive.openBox('cache');
  } catch (e) {
    print('[TA] Hive init error: $e');
  }

  // 初始化通知服务
  final notificationService = NotificationService();
  await notificationService.initialize();
  
  // 检查是否启用了通知
  final settingsBox = Hive.box('settings');
  final morningEnabled = settingsBox.get('morningGreeting', defaultValue: true);
  final noonEnabled = settingsBox.get('noonShare', defaultValue: true);
  final eveningEnabled = settingsBox.get('eveningChat', defaultValue: true);
  final nightEnabled = settingsBox.get('nightCare', defaultValue: true);
  
  if (morningEnabled) {
    await notificationService.scheduleDailyNotification(
      id: 1,
      hour: 8,
      minute: 0,
      title: '早安 ☀️',
      body: '新的一天开始了，今天也要开心哦~',
    );
  }
  
  if (noonEnabled) {
    await notificationService.scheduleDailyNotification(
      id: 2,
      hour: 12,
      minute: 0,
      title: '午安 🍱',
      body: '吃饭了吗？记得照顾好自己~',
    );
  }
  
  if (eveningEnabled) {
    await notificationService.scheduleDailyNotification(
      id: 3,
      hour: 18,
      minute: 0,
      title: '傍晚好 🌅',
      body: '辛苦一天了，放松一下吧~',
    );
  }
  
  if (nightEnabled) {
    await notificationService.scheduleDailyNotification(
      id: 4,
      hour: 22,
      minute: 0,
      title: '晚安 🌙',
      body: '早点休息，明天见~',
    );
  }

  runApp(
    const ProviderScope(
      child: TaCompanionApp(),
    ),
  );
}
