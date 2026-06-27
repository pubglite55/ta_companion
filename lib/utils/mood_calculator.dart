import '../models/mood.dart';

class MoodCalculator {
  static Mood calculate({
    required String weatherCondition,
    required double newsSentiment,
    required int lastInteractionHoursAgo,
    required int hourOfDay,
    bool userSentHeart = false,
  }) {
    if (userSentHeart) {
      return Mood(
        type: MoodType.sweet,
        score: 1.0,
        timestamp: DateTime.now(),
      );
    }

    final weatherScore = _getWeatherScore(weatherCondition);
    final interactionScore = _getInteractionScore(lastInteractionHoursAgo);
    final timeScore = _getTimeScore(hourOfDay);
    final totalScore = (weatherScore * 0.3) +
        (newsSentiment * 0.2) +
        (interactionScore * 0.3) +
        (timeScore * 0.2);

    MoodType type;
    if (totalScore > 0.7) {
      type = MoodType.happy;
    } else if (totalScore > 0.4) {
      type = MoodType.calm;
    } else if (totalScore > 0.2) {
      type = MoodType.sad;
    } else {
      type = MoodType.sleepy;
    }

    if (hourOfDay >= 21 || hourOfDay < 6) {
      type = MoodType.sleepy;
    }

    return Mood(
      type: type,
      score: totalScore,
      timestamp: DateTime.now(),
    );
  }

  static double _getWeatherScore(String condition) {
    if (condition.contains('晴')) return 1.0;
    if (condition.contains('多云')) return 0.6;
    if (condition.contains('雨')) return 0.3;
    if (condition.contains('雪')) return 0.4;
    return 0.5;
  }

  static double _getInteractionScore(int hoursAgo) {
    if (hoursAgo <= 2) return 1.0;
    if (hoursAgo <= 6) return 0.6;
    if (hoursAgo <= 12) return 0.3;
    return 0.1;
  }

  static double _getTimeScore(int hour) {
    if (hour >= 8 && hour < 18) return 0.8;
    if (hour >= 18 && hour < 21) return 0.6;
    return 0.3;
  }
}
