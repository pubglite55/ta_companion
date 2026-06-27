enum MessageType {
  text,
  image,
  song,
  system,
}

class Message {
  final String id;
  final String content;
  final bool isFromCompanion;
  final MessageType type;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const Message({
    required this.id,
    required this.content,
    required this.isFromCompanion,
    required this.type,
    required this.timestamp,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'isFromCompanion': isFromCompanion,
    'type': type.index,
    'timestamp': timestamp.toIso8601String(),
    'metadata': metadata,
  };

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json['id'],
    content: json['content'],
    isFromCompanion: json['isFromCompanion'],
    type: MessageType.values[json['type']],
    timestamp: DateTime.parse(json['timestamp']),
    metadata: json['metadata'],
  );
}
