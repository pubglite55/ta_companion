enum IntimacyLevel {
  stranger,    // 陌生人 0-10
  acquaintance, // 认识 11-30
  friend,      // 朋友 31-50
  closeFriend, // 好友 51-70
  bestFriend,  // 挚友 71-90
  soulmate,    // 灵魂伴侣 91-100
}

class Intimacy {
  final int score;
  final int totalChats;
  final int totalLikes;
  final int totalComments;
  final DateTime lastInteraction;
  final List<String> milestones;

  const Intimacy({
    required this.score,
    required this.totalChats,
    required this.totalLikes,
    required this.totalComments,
    required this.lastInteraction,
    this.milestones = const [],
  });

  IntimacyLevel get level {
    if (score >= 91) return IntimacyLevel.soulmate;
    if (score >= 71) return IntimacyLevel.bestFriend;
    if (score >= 51) return IntimacyLevel.closeFriend;
    if (score >= 31) return IntimacyLevel.friend;
    if (score >= 11) return IntimacyLevel.acquaintance;
    return IntimacyLevel.stranger;
  }

  String get levelLabel {
    switch (level) {
      case IntimacyLevel.soulmate:
        return '灵魂伴侣';
      case IntimacyLevel.bestFriend:
        return '挚友';
      case IntimacyLevel.closeFriend:
        return '好友';
      case IntimacyLevel.friend:
        return '朋友';
      case IntimacyLevel.acquaintance:
        return '认识';
      case IntimacyLevel.stranger:
        return '陌生人';
    }
  }

  String get levelEmoji {
    switch (level) {
      case IntimacyLevel.soulmate:
        return '💕';
      case IntimacyLevel.bestFriend:
        return '💖';
      case IntimacyLevel.closeFriend:
        return '💙';
      case IntimacyLevel.friend:
        return '💚';
      case IntimacyLevel.acquaintance:
        return '💛';
      case IntimacyLevel.stranger:
        return '🤍';
    }
  }

  double get progress {
    final ranges = [
      (0, 10, 0.0),
      (11, 30, 0.1),
      (31, 50, 0.3),
      (51, 70, 0.5),
      (71, 90, 0.7),
      (91, 100, 0.9),
    ];
    for (final r in ranges) {
      if (score >= r.$1 && score <= r.$2) {
        return r.$3 + (score - r.$1) / (r.$2 - r.$1) * 0.2;
      }
    }
    return 1.0;
  }

  Intimacy copyWith({
    int? score,
    int? totalChats,
    int? totalLikes,
    int? totalComments,
    DateTime? lastInteraction,
    List<String>? milestones,
  }) {
    return Intimacy(
      score: score ?? this.score,
      totalChats: totalChats ?? this.totalChats,
      totalLikes: totalLikes ?? this.totalLikes,
      totalComments: totalComments ?? this.totalComments,
      lastInteraction: lastInteraction ?? this.lastInteraction,
      milestones: milestones ?? this.milestones,
    );
  }

  Map<String, dynamic> toJson() => {
    'score': score,
    'totalChats': totalChats,
    'totalLikes': totalLikes,
    'totalComments': totalComments,
    'lastInteraction': lastInteraction.toIso8601String(),
    'milestones': milestones,
  };

  factory Intimacy.fromJson(Map<String, dynamic> json) => Intimacy(
    score: json['score'] ?? 0,
    totalChats: json['totalChats'] ?? 0,
    totalLikes: json['totalLikes'] ?? 0,
    totalComments: json['totalComments'] ?? 0,
    lastInteraction: DateTime.tryParse(json['lastInteraction'] ?? '') ?? DateTime.now(),
    milestones: List<String>.from(json['milestones'] ?? []),
  );
}
