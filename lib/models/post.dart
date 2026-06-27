enum PostType {
  text,
  image,
  song,
  quote,
}

class Post {
  final String id;
  final String content;
  final PostType type;
  final DateTime timestamp;
  final int likes;
  final int comments;
  final Map<String, dynamic>? media;

  const Post({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.likes = 0,
    this.comments = 0,
    this.media,
  });

  Post copyWith({
    String? content,
    int? likes,
    int? comments,
    Map<String, dynamic>? media,
  }) {
    return Post(
      id: id,
      content: content ?? this.content,
      type: type,
      timestamp: timestamp,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      media: media ?? this.media,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'type': type.index,
    'timestamp': timestamp.toIso8601String(),
    'likes': likes,
    'comments': comments,
    'media': media,
  };

  factory Post.fromJson(Map<String, dynamic> json) => Post(
    id: json['id'],
    content: json['content'],
    type: PostType.values[json['type']],
    timestamp: DateTime.parse(json['timestamp']),
    likes: json['likes'] ?? 0,
    comments: json['comments'] ?? 0,
    media: json['media'],
  );
}
