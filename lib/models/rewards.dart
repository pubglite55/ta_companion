import 'intimacy.dart';

class Reward {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final IntimacyLevel requiredLevel;
  final bool isUnlocked;

  const Reward({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.requiredLevel,
    this.isUnlocked = false,
  });

  Reward copyWith({bool? isUnlocked}) {
    return Reward(
      id: id,
      title: title,
      description: description,
      emoji: emoji,
      requiredLevel: requiredLevel,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }
}

class RewardSystem {
  static const List<Reward> allRewards = [
    // 陌生人 0-10
    Reward(
      id: 'greeting',
      title: '专属问候',
      description: 'TA会用特别的方式和你打招呼',
      emoji: '👋',
      requiredLevel: IntimacyLevel.stranger,
    ),
    // 认识 11-30
    Reward(
      id: 'nickname',
      title: '专属昵称',
      description: 'TA会给你起一个可爱的昵称',
      emoji: '💌',
      requiredLevel: IntimacyLevel.acquaintance,
    ),
    Reward(
      id: 'daily_topic',
      title: '每日话题',
      description: 'TA会主动找你聊天',
      emoji: '💬',
      requiredLevel: IntimacyLevel.acquaintance,
    ),
    // 朋友 31-50
    Reward(
      id: 'secret',
      title: '分享秘密',
      description: 'TA会和你分享小秘密',
      emoji: '🤫',
      requiredLevel: IntimacyLevel.friend,
    ),
    Reward(
      id: 'mood_boost',
      title: '心情加成',
      description: '互动时亲密度增加更多',
      emoji: '✨',
      requiredLevel: IntimacyLevel.friend,
    ),
    // 好友 51-70
    Reward(
      id: 'special_emoji',
      title: '专属表情',
      description: '解锁TA的专属表情包',
      emoji: '😍',
      requiredLevel: IntimacyLevel.closeFriend,
    ),
    Reward(
      id: 'voice_message',
      title: '语音消息',
      description: 'TA可以给你发语音',
      emoji: '🎤',
      requiredLevel: IntimacyLevel.closeFriend,
    ),
    // 挚友 71-90
    Reward(
      id: 'love_confession',
      title: '甜蜜告白',
      description: 'TA会偶尔对你表白',
      emoji: '💕',
      requiredLevel: IntimacyLevel.bestFriend,
    ),
    Reward(
      id: 'anniversary',
      title: '纪念日',
      description: 'TA会记住你们的特别日子',
      emoji: '🎉',
      requiredLevel: IntimacyLevel.bestFriend,
    ),
    // 灵魂伴侣 91-100
    Reward(
      id: 'soulmate_title',
      title: '灵魂伴侣',
      description: '你获得了最高称号',
      emoji: '👑',
      requiredLevel: IntimacyLevel.soulmate,
    ),
    Reward(
      id: 'forever_promise',
      title: '永恒承诺',
      description: 'TA会给你一个永远的承诺',
      emoji: '💍',
      requiredLevel: IntimacyLevel.soulmate,
    ),
  ];

  static List<Reward> getRewardsForLevel(IntimacyLevel level) {
    final levelIndex = IntimacyLevel.values.indexOf(level);
    return allRewards.map((r) {
      final requiredIndex = IntimacyLevel.values.indexOf(r.requiredLevel);
      return r.copyWith(isUnlocked: levelIndex >= requiredIndex);
    }).toList();
  }

  static List<Reward> getUnlockedRewards(IntimacyLevel level) {
    return getRewardsForLevel(level).where((r) => r.isUnlocked).toList();
  }

  static List<Reward> getLockedRewards(IntimacyLevel level) {
    return getRewardsForLevel(level).where((r) => !r.isUnlocked).toList();
  }
}
