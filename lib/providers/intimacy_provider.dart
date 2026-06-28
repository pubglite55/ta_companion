import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/intimacy.dart';

class IntimacyProvider extends StateNotifier<Intimacy> {
  final Box _box = Hive.box('cache');

  IntimacyProvider()
      : super(Intimacy(
          score: 0,
          totalChats: 0,
          totalLikes: 0,
          totalComments: 0,
          lastInteraction: DateTime.now(),
        )) {
    _loadIntimacy();
  }

  void _loadIntimacy() {
    try {
      final saved = _box.get('intimacy');
      if (saved != null && saved is Map) {
        state = Intimacy.fromJson(Map<String, dynamic>.from(saved));
      }
    } catch (e) {
      print('[Intimacy] Load error: $e');
    }
  }

  void _saveIntimacy() {
    try {
      _box.put('intimacy', state.toJson());
    } catch (e) {
      print('[Intimacy] Save error: $e');
    }
  }

  void onChat() {
    final newScore = (state.score + 2).clamp(0, 100);
    final oldLevel = state.level;
    final newIntimacy = state.copyWith(
      score: newScore,
      totalChats: state.totalChats + 1,
      lastInteraction: DateTime.now(),
    );
    final newLevel = newIntimacy.level;

    if (oldLevel != newLevel) {
      final milestones = List<String>.from(newIntimacy.milestones);
      milestones.add('${DateTime.now().toIso8601String()}:升级到${newIntimacy.levelLabel}');
      state = newIntimacy.copyWith(milestones: milestones);
    } else {
      state = newIntimacy;
    }
    _saveIntimacy();
  }

  void onLike() {
    final newScore = (state.score + 1).clamp(0, 100);
    state = state.copyWith(
      score: newScore,
      totalLikes: state.totalLikes + 1,
      lastInteraction: DateTime.now(),
    );
    _saveIntimacy();
  }

  void onComment() {
    final newScore = (state.score + 3).clamp(0, 100);
    state = state.copyWith(
      score: newScore,
      totalComments: state.totalComments + 1,
      lastInteraction: DateTime.now(),
    );
    _saveIntimacy();
  }

  void onReply() {
    final newScore = (state.score + 2).clamp(0, 100);
    state = state.copyWith(
      score: newScore,
      lastInteraction: DateTime.now(),
    );
    _saveIntimacy();
  }
}

final intimacyProvider = StateNotifierProvider<IntimacyProvider, Intimacy>((ref) {
  return IntimacyProvider();
});
