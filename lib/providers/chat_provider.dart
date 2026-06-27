import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message.dart';
import '../services/ai_service.dart';
import 'settings_provider.dart';

class ChatProvider extends StateNotifier<List<Message>> {
  final Ref ref;
  final AiService _aiService = AiService();

  ChatProvider(this.ref) : super([]);

  Future<void> sendMessage(String content) async {
    final userMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isFromCompanion: false,
      type: MessageType.text,
      timestamp: DateTime.now(),
    );

    state = [...state, userMessage];

    final settings = ref.read(settingsProvider);
    if (settings.aiApiKey == null || settings.aiProvider == null) {
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

    final response = await _aiService.sendMessage(
      provider: settings.aiProvider!,
      apiKey: settings.aiApiKey!,
      systemPrompt: '你是${settings.companionName}，一个${settings.companionPersonality}的AI伴侣。',
      messages: state
          .where((m) => m.id != aiMessage.id)
          .map((m) => {
                'role': m.isFromCompanion ? 'assistant' : 'user',
                'content': m.content,
              })
          .toList(),
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
  }

  void clearChat() {
    state = [];
  }
}

final chatProvider = StateNotifierProvider<ChatProvider, List<Message>>((ref) {
  return ChatProvider(ref);
});
