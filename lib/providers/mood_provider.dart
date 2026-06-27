import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/mood.dart';
import '../utils/mood_calculator.dart';
import '../services/weather_service.dart';

class MoodProvider extends StateNotifier<Mood> {
  final Ref ref;
  final WeatherService _weatherService = WeatherService();
  final Box _box = Hive.box('cache');

  MoodProvider(this.ref)
      : super(Mood(
          type: MoodType.calm,
          score: 0.5,
          timestamp: DateTime.now(),
        )) {
    _loadTodayMood();
  }

  // 加载今日心情
  void _loadTodayMood() {
    try {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final saved = _box.get('mood_$today');
      if (saved != null && saved is Map) {
        state = Mood.fromJson(Map<String, dynamic>.from(saved));
      }
    } catch (e) {
      print('[Mood] Load error: $e');
    }
  }

  // 保存心情记录
  void _saveMood() {
    try {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      _box.put('mood_$today', state.toJson());

      // 保存到心情历史列表
      final history = _box.get('mood_history', defaultValue: []) as List;
      final todayIndex = history.indexWhere((h) => h is Map && h['date'] == today);
      final record = {
        'date': today,
        'type': state.type.index,
        'score': state.score,
      };
      if (todayIndex >= 0) {
        history[todayIndex] = record;
      } else {
        history.add(record);
      }
      // 只保留最近30天
      if (history.length > 30) {
        history.removeRange(0, history.length - 30);
      }
      _box.put('mood_history', history);
    } catch (e) {
      print('[Mood] Save error: $e');
    }
  }

  // 获取心情历史
  List<Map<String, dynamic>> getMoodHistory() {
    try {
      final history = _box.get('mood_history', defaultValue: []) as List;
      return history.map((h) => Map<String, dynamic>.from(h)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> updateMood() async {
    final weather = await _weatherService.getCurrentWeather(39.9042, 116.4074);

    final mood = MoodCalculator.calculate(
      weatherCondition: weather?.condition ?? '多云',
      newsSentiment: 0.5,
      lastInteractionHoursAgo: 1,
      hourOfDay: DateTime.now().hour,
    );

    state = mood;
    _saveMood();
  }

  // 手动设置心情
  void setMood(MoodType type) {
    state = Mood(
      type: type,
      score: type == MoodType.happy ? 1.0 : type == MoodType.sad ? 0.2 : 0.5,
      timestamp: DateTime.now(),
    );
    _saveMood();
  }
}

final moodProvider = StateNotifierProvider<MoodProvider, Mood>((ref) {
  return MoodProvider(ref);
});
