enum MemoryType {
  personal,    // 个人信息（名字、生日等）
  preference,  // 偏好（喜欢的东西）
  event,       // 事件（去过的地方、做过的事）
  emotion,     // 情感（开心的事、难过的事）
}

class Memory {
  final String id;
  final String content;
  final MemoryType type;
  final DateTime timestamp;
  final String? context;
  final int importance;

  const Memory({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.context,
    this.importance = 1,
  });

  String get typeEmoji {
    switch (type) {
      case MemoryType.personal:
        return '👤';
      case MemoryType.preference:
        return '💜';
      case MemoryType.event:
        return '📅';
      case MemoryType.emotion:
        return '💭';
    }
  }

  String get typeLabel {
    switch (type) {
      case MemoryType.personal:
        return '个人信息';
      case MemoryType.preference:
        return '偏好';
      case MemoryType.event:
        return '事件';
      case MemoryType.emotion:
        return '情感';
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'type': type.index,
    'timestamp': timestamp.toIso8601String(),
    'context': context,
    'importance': importance,
  };

  factory Memory.fromJson(Map<String, dynamic> json) => Memory(
    id: json['id'] ?? '',
    content: json['content'] ?? '',
    type: MemoryType.values[json['type'] ?? 0],
    timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    context: json['context'],
    importance: json['importance'] ?? 1,
  );
}
