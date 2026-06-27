import 'package:flutter_test/flutter_test.dart';
import 'package:ta_companion/utils/mood_calculator.dart';
import 'package:ta_companion/models/mood.dart';

void main() {
  group('MoodCalculator', () {
    test('returns happy mood for sunny weather and recent interaction', () {
      final mood = MoodCalculator.calculate(
        weatherCondition: '晴',
        newsSentiment: 0.5,
        lastInteractionHoursAgo: 1,
        hourOfDay: 12,
      );
      expect(mood.type, MoodType.happy);
    });

    test('returns sad mood for rainy weather and no interaction', () {
      final mood = MoodCalculator.calculate(
        weatherCondition: '雨',
        newsSentiment: 0.3,
        lastInteractionHoursAgo: 24,
        hourOfDay: 20,
      );
      expect(mood.type, MoodType.sad);
    });

    test('returns sleepy mood for late night', () {
      final mood = MoodCalculator.calculate(
        weatherCondition: '晴',
        newsSentiment: 0.5,
        lastInteractionHoursAgo: 2,
        hourOfDay: 23,
      );
      expect(mood.type, MoodType.sleepy);
    });

    test('returns sweet mood when user sends heart', () {
      final mood = MoodCalculator.calculate(
        weatherCondition: '晴',
        newsSentiment: 0.5,
        lastInteractionHoursAgo: 0,
        hourOfDay: 12,
        userSentHeart: true,
      );
      expect(mood.type, MoodType.sweet);
    });
  });
}
