import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mood.dart';
import '../utils/mood_calculator.dart';
import '../services/weather_service.dart';
import 'settings_provider.dart';

class MoodProvider extends StateNotifier<Mood> {
  final Ref ref;
  final WeatherService _weatherService = WeatherService();

  MoodProvider(this.ref)
      : super(Mood(
          type: MoodType.calm,
          score: 0.5,
          timestamp: DateTime.now(),
        ));

  Future<void> updateMood() async {
    final weather = await _weatherService.getCurrentWeather(39.9042, 116.4074);

    final mood = MoodCalculator.calculate(
      weatherCondition: weather?.condition ?? '多云',
      newsSentiment: 0.5,
      lastInteractionHoursAgo: 1,
      hourOfDay: DateTime.now().hour,
    );

    state = mood;
  }

  void triggerSweetMood() {
    state = Mood(
      type: MoodType.sweet,
      score: 1.0,
      timestamp: DateTime.now(),
    );
  }
}

final moodProvider = StateNotifierProvider<MoodProvider, Mood>((ref) {
  return MoodProvider(ref);
});
