import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/message.dart';
import '../services/ai_service.dart';
import 'settings_provider.dart';

class ChatProvider extends StateNotifier<List<Message>> {
  final Ref ref;
  final AiService _aiService = AiService();
  final Box _chatBox = Hive.box('cache');

  ChatProvider(this.ref) : super([]) {
    _loadHistory();
  }

  // 加载历史记录
  void _loadHistory() {
    try {
      final history = _chatBox.get('chat_history', defaultValue: []) as List;
      state = history.map((item) {
        if (item is Map) {
          return Message(
            id: item['id'] ?? '',
            content: item['content'] ?? '',
            isFromCompanion: item['isFromCompanion'] ?? false,
            type: MessageType.values[item['type'] ?? 0],
            timestamp: DateTime.tryParse(item['timestamp'] ?? '') ?? DateTime.now(),
          );
        }
        return null;
      }).where((m) => m != null).cast<Message>().toList();
    } catch (e) {
      print('[Chat] Load history error: $e');
      state = [];
    }
  }

  // 保存历史记录
  void _saveHistory() {
    try {
      final history = state.map((m) => {
        'id': m.id,
        'content': m.content,
        'isFromCompanion': m.isFromCompanion,
        'type': m.type.index,
        'timestamp': m.timestamp.toIso8601String(),
      }).toList();
      _chatBox.put('chat_history', history);
    } catch (e) {
      print('[Chat] Save history error: $e');
    }
  }

  Future<void> sendMessage(String content) async {
    final userMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isFromCompanion: false,
      type: MessageType.text,
      timestamp: DateTime.now(),
    );

    state = [...state, userMessage];
    _saveHistory();

    final settings = ref.read(settingsProvider);
    if (settings.aiApiKey == null || settings.aiApiKey!.isEmpty) {
      final tipMessage = Message(
        id: '${DateTime.now().millisecondsSinceEpoch}_tip',
        content: '👋 请先去设置配置 AI 服务和 API Key',
        isFromCompanion: true,
        type: MessageType.system,
        timestamp: DateTime.now(),
      );
      state = [...state, tipMessage];
      _saveHistory();
      return;
    }

    final aiMessage = Message(
      id: '${DateTime.now().millisecondsSinceEpoch}_ai',
      content: '思考中...',
      isFromCompanion: true,
      type: MessageType.text,
      timestamp: DateTime.now(),
    );

    state = [...state, aiMessage];
    _saveHistory();

    final response = await _aiService.sendMessage(
      provider: settings.aiProvider!,
      apiKey: settings.aiApiKey!,
      systemPrompt: settings.customPrompt ?? '你是${settings.companionName}，一个${settings.companionPersonality}的AI伴侣。你说话亲密有情趣，像一个特别爱你的人。',
      messages: state
          .where((m) => m.id != aiMessage.id)
          .map((m) => {
                'role': m.isFromCompanion ? 'assistant' : 'user',
                'content': m.content,
              })
          .toList(),
      baseUrl: settings.aiBaseUrl,
      model: settings.aiModel,
    );

    state = state.map((m) {
      if (m.id == aiMessage.id) {
        return Message(
          id: m.id,
          content: response,
          isFromCompanion: true,
          type: MessageType.text,
          timestamp: m.timestamp,
        );
      }
      return m;
    }).toList();

    _saveHistory();
  }

  void clearChat() {
    state = [];
    _chatBox.delete('chat_history');
  }
}

final chatProvider = StateNotifierProvider<ChatProvider, List<Message>>((ref) {
  return ChatProvider(ref);
});
