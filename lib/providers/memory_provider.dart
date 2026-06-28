import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/memory.dart';

class MemoryProvider extends StateNotifier<List<Memory>> {
  final Box _box = Hive.box('cache');

  MemoryProvider() : super([]) {
    _loadMemories();
  }

  void _loadMemories() {
    try {
      final saved = _box.get('memories', defaultValue: []) as List;
      state = saved.map((item) {
        if (item is Map) {
          return Memory.fromJson(Map<String, dynamic>.from(item));
        }
        return null;
      }).where((m) => m != null).cast<Memory>().toList();
    } catch (e) {
      print('[Memory] Load error: $e');
      state = [];
    }
  }

  void _saveMemories() {
    try {
      final data = state.map((m) => m.toJson()).toList();
      _box.put('memories', data);
    } catch (e) {
      print('[Memory] Save error: $e');
    }
  }

  void addMemory(String content, MemoryType type, {String? context, int importance = 1}) {
    final memory = Memory(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      content: content,
      type: type,
      timestamp: DateTime.now(),
      context: context,
      importance: importance,
    );
    state = [memory, ...state];
    _saveMemories();
  }

  void removeMemory(String id) {
    state = state.where((m) => m.id != id).toList();
    _saveMemories();
  }

  List<Memory> getMemoriesByType(MemoryType type) {
    return state.where((m) => m.type == type).toList();
  }

  List<Memory> getImportantMemories() {
    return state.where((m) => m.importance >= 2).toList()
      ..sort((a, b) => b.importance.compareTo(a.importance));
  }

  String getMemoryContext() {
    if (state.isEmpty) return '';
    final important = getImportantMemories();
    if (important.isEmpty) return '';
    return '关于用户的重要信息：${important.map((m) => m.content).join('；')}';
  }

  void onChat(String message) {
    final lower = message.toLowerCase();

    // 检测个人信息
    if (lower.contains('我叫') || lower.contains('我的名字')) {
      final name = _extractName(message);
      if (name != null) {
        addMemory('用户的名字是$name', MemoryType.personal, importance: 3);
      }
    }

    if (lower.contains('我生日') || lower.contains('我生在')) {
      addMemory('用户提到了生日', MemoryType.personal, context: message, importance: 2);
    }

    // 检测偏好
    if (lower.contains('我喜欢') || lower.contains('我爱') || lower.contains('我偏好')) {
      addMemory(message, MemoryType.preference, importance: 2);
    }

    if (lower.contains('我不喜欢') || lower.contains('我讨厌')) {
      addMemory(message, MemoryType.preference, importance: 2);
    }

    // 检测情感
    if (lower.contains('开心') || lower.contains('高兴') || lower.contains('快乐')) {
      addMemory('用户分享了开心的事情', MemoryType.emotion, context: message, importance: 1);
    }

    if (lower.contains('难过') || lower.contains('伤心') || lower.contains('不开心')) {
      addMemory('用户分享了难过的事情', MemoryType.emotion, context: message, importance: 2);
    }

    // 检测事件
    if (lower.contains('我去过') || lower.contains('我去了') || lower.contains('我旅行')) {
      addMemory('用户分享了旅行经历', MemoryType.event, context: message, importance: 1);
    }
  }

  String? _extractName(String message) {
    final patterns = [
      RegExp(r'我叫(\S+)'),
      RegExp(r'我的名字是(\S+)'),
      RegExp(r'我是(\S+)'),
    ];
    for (final pattern in patterns) {
      final match = pattern.firstMatch(message);
      if (match != null) {
        return match.group(1);
      }
    }
    return null;
  }
}

final memoryProvider = StateNotifierProvider<MemoryProvider, List<Memory>>((ref) {
  return MemoryProvider();
});
