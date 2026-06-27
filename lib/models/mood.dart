enum MoodType {
  happy,     // 😊 开心
  sad,       // 😢 忧郁
  sleepy,    // 😴 困倦
  sweet,     // 😍 甜蜜
  thinking,  // 🤔 思考
  calm,      // 😌 平静
}

class Mood {
  final MoodType type;
  final double score;
  final DateTime timestamp;

  const Mood({
    required this.type,
    required this.score,
    required this.timestamp,
  });

  String get emoji {
    switch (type) {
      case MoodType.happy:
        return '😊';
      case MoodType.sad:
        return '😢';
      case MoodType.sleepy:
        return '😴';
      case MoodType.sweet:
        return '😍';
      case MoodType.thinking:
        return '🤔';
      case MoodType.calm:
        return '😌';
    }
  }

  String get label {
    switch (type) {
      case MoodType.happy:
        return '开心';
      case MoodType.sad:
        return '忧郁';
      case MoodType.sleepy:
        return '困倦';
      case MoodType.sweet:
        return '甜蜜';
      case MoodType.thinking:
        return '思考';
      case MoodType.calm:
        return '平静';
    }
  }

  Map<String, dynamic> toJson() => {
    'type': type.index,
    'score': score,
    'timestamp': timestamp.toIso8601String(),
  };

  factory Mood.fromJson(Map<String, dynamic> json) => Mood(
    type: MoodType.values[json['type']],
    score: json['score'].toDouble(),
    timestamp: DateTime.parse(json['timestamp']),
  );
}
