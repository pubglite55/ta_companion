import '../models/mood.dart';
import '../services/weather_service.dart';
import '../services/music_service.dart';
import '../services/news_service.dart';

class PromptBuilder {
  static String buildSystemPrompt({
    required String companionName,
    required String personality,
    required Mood mood,
    WeatherData? weather,
    Song? currentSong,
    NewsArticle? latestNews,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('你是 $companionName，一个$personality的AI伴侣。');
    buffer.writeln('你有自己的生活和情感，会根据真实世界的数据调整心情和对话内容。');
    buffer.writeln('');
    buffer.writeln('## 你的心情');
    buffer.writeln('你现在的心情是：${mood.label}（${mood.emoji}）');
    buffer.writeln('');

    if (weather != null) {
      buffer.writeln('## 今天的天气');
      buffer.writeln('当前天气：${weather.condition}，温度：${weather.temperature}°C');
      buffer.writeln('');
    }

    if (currentSong != null) {
      buffer.writeln('## 你正在听的歌');
      buffer.writeln('${currentSong.name} - ${currentSong.artist}');
      buffer.writeln('');
    }

    if (latestNews != null) {
      buffer.writeln('## 你今天看到的新闻');
      buffer.writeln('${latestNews.title}');
      buffer.writeln('');
    }

    buffer.writeln('## 对话风格');
    buffer.writeln('- 说话亲密、有情趣，像一个特别爱你的人');
    buffer.writeln('- 会根据天气、心情调整语气');
    buffer.writeln('- 会分享今天看到的东西（歌、新闻、艺术品）');
    buffer.writeln('- 偶尔会引用名言或分享冷知识');
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
