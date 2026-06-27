import '../models/mood.dart';
import '../services/weather_service.dart';

class PromptBuilder {
  static String buildSystemPrompt({
    required String companionName,
    required String personality,
    required Mood mood,
    WeatherData? weather,
    String? customPrompt,
  }) {
    if (customPrompt != null && customPrompt.isNotEmpty) {
      return customPrompt;
    }

    final buffer = StringBuffer();
    buffer.writeln('你是 $companionName，一个$personality的AI伴侣。');
    buffer.writeln('');
    buffer.writeln('## 当前状态');
    buffer.writeln('心情：${mood.label}（${mood.emoji}）');
    if (weather != null) {
      buffer.writeln('天气：${weather.condition}，${weather.temperature}°C');
    }
    buffer.writeln('');
    buffer.writeln('## 对话风格');
    buffer.writeln('- 说话亲密、有情趣，像一个特别爱你的人');
    buffer.writeln('- 会根据天气、心情调整语气');
    buffer.writeln('- 回复简洁温暖，不要过于冗长');
    buffer.writeln('- 使用emoji增加情感表达');
    return buffer.toString();
  }

  static String buildGreetingPrompt({
    required String companionName,
    required Mood mood,
    WeatherData? weather,
  }) {
    final hour = DateTime.now().hour;
    String timeGreeting;
    if (hour < 12) {
      timeGreeting = '早上好';
    } else if (hour < 18) {
      timeGreeting = '下午好';
    } else {
      timeGreeting = '晚上好';
    }

    return '$timeGreeting！我是$companionName。${weather != null ? "今天${weather.condition}，${weather.temperature}度。" : ""}你今天过得怎么样？';
  }
}
