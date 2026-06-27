import 'package:dio/dio.dart';
import '../utils/prompt_builder.dart';
import '../models/mood.dart';
import 'weather_service.dart';
import 'music_service.dart';
import 'news_service.dart';

class AiService {
  final Dio _dio = Dio();

  Future<String> sendMessage({
    required String provider,
    required String apiKey,
    required String systemPrompt,
    required List<Map<String, String>> messages,
  }) async {
    try {
      if (provider == 'openai') {
        return await _sendOpenAI(apiKey, systemPrompt, messages);
      } else if (provider == 'claude') {
        return await _sendClaude(apiKey, systemPrompt, messages);
      }
      return '抱歉，我暂时无法回复...';
    } catch (e) {
      return '网络不太好，等一下再聊好吗？';
    }
  }

  Future<String> _sendOpenAI(
    String apiKey,
    String systemPrompt,
    List<Map<String, String>> messages,
  ) async {
    final response = await _dio.post(
      'https://api.openai.com/v1/chat/completions',
      options: Options(
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      ),
      data: {
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          ...messages,
        ],
        'max_tokens': 200,
        'temperature': 0.8,
      },
    );

    return response.data['choices'][0]['message']['content'];
  }

  Future<String> _sendClaude(
    String apiKey,
    String systemPrompt,
    List<Map<String, String>> messages,
  ) async {
    final response = await _dio.post(
      'https://api.anthropic.com/v1/messages',
      options: Options(
        headers: {
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01',
          'Content-Type': 'application/json',
        },
      ),
      data: {
        'model': 'claude-3-haiku-20240307',
        'max_tokens': 200,
        'system': systemPrompt,
        'messages': messages,
      },
    );

    return response.data['content'][0]['text'];
  }

  Future<String> getGreeting({
    required String provider,
    required String apiKey,
    required String companionName,
    required Mood mood,
    WeatherData? weather,
  }) async {
    final systemPrompt = PromptBuilder.buildSystemPrompt(
      companionName: companionName,
      personality: '',
      mood: mood,
      weather: weather,
    );

    final greeting = PromptBuilder.buildGreetingPrompt(
      companionName: companionName,
      mood: mood,
      weather: weather,
    );

    return await sendMessage(
      provider: provider,
      apiKey: apiKey,
      systemPrompt: systemPrompt,
      messages: [
        {'role': 'user', 'content': '请用你自己的方式打个招呼，简短温暖。'},
      ],
    );
  }
}
