import 'package:dio/dio.dart';
import '../utils/prompt_builder.dart';
import '../models/mood.dart';
import 'weather_service.dart';
import 'news_service.dart';

class AiService {
  final Dio _dio = Dio();

  Future<String> sendMessage({
    required String provider,
    required String apiKey,
    required String systemPrompt,
    required List<Map<String, String>> messages,
    String? baseUrl,
    String? model,
  }) async {
    try {
      print('[TA] Sending to: provider=$provider, model=$model, baseUrl=$baseUrl');
      if (provider == 'claude') {
        return await _sendClaude(apiKey, systemPrompt, messages, baseUrl, model);
      }
      // OpenAI, DeepSeek, 智谱, and custom providers all use OpenAI-compatible API
      return await _sendOpenAICompatible(apiKey, systemPrompt, messages, provider, baseUrl, model);
    } catch (e) {
      print('[TA] Error: $e');
      return '请求失败: ${e.toString()}';
    }
  }

  String _getBaseUrl(String provider, String? customBaseUrl) {
    // 处理用户输入的 URL
    if (customBaseUrl != null && customBaseUrl.isNotEmpty) {
      String url = customBaseUrl.trimRight().replaceAll(RegExp(r'/+$'), '');
      // 如果用户没有输入完整路径，自动补全
      if (!url.endsWith('/chat/completions') && !url.endsWith('/messages')) {
        url = '$url/chat/completions';
      }
      return url;
    }
    switch (provider) {
      case 'openai':
        return 'https://api.openai.com/v1/chat/completions';
      case 'deepseek':
        return 'https://api.deepseek.com/v1/chat/completions';
      case 'zhipu':
        return 'https://open.bigmodel.cn/api/paas/v4/chat/completions';
      case 'claude':
        return 'https://api.anthropic.com/v1/messages';
      default:
        return '';
    }
  }

  String _getModel(String provider) {
    switch (provider) {
      case 'openai':
        return 'gpt-3.5-turbo';
      case 'deepseek':
        return 'deepseek-chat';
      case 'zhipu':
        return 'glm-4-flash';
      case 'claude':
        return 'claude-3-haiku-20240307';
      default:
        return 'gpt-3.5-turbo';
    }
  }

  Future<String> _sendOpenAICompatible(
    String apiKey,
    String systemPrompt,
    List<Map<String, String>> messages,
    String provider,
    String? baseUrl,
    String? model,
  ) async {
    final url = _getBaseUrl(provider, baseUrl);
    if (url.isEmpty) {
      return '请配置 API Base URL';
    }

    final response = await _dio.post(
      url,
      options: Options(
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      ),
      data: {
        'model': model ?? _getModel(provider),
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
    String? baseUrl,
    String? model,
  ) async {
    final url = baseUrl ?? 'https://api.anthropic.com/v1/messages';

    final response = await _dio.post(
      url,
      options: Options(
        headers: {
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01',
          'Content-Type': 'application/json',
        },
      ),
      data: {
        'model': model ?? 'claude-3-haiku-20240307',
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
    String? baseUrl,
    String? model,
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
      baseUrl: baseUrl,
      model: model,
    );
  }
}
