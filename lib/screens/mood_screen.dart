import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/colors.dart';
import '../models/mood.dart';
import '../providers/mood_provider.dart';

class MoodScreen extends ConsumerWidget {
  const MoodScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mood = ref.watch(moodProvider);
    final moodNotifier = ref.read(moodProvider.notifier);
    final history = moodNotifier.getMoodHistory();

    return Scaffold(
      appBar: AppBar(
        title: const Text('心情统计'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 当前心情
          _buildCurrentMood(mood),
          const SizedBox(height: 20),
          // 心情选择
          _buildMoodSelector(ref),
          const SizedBox(height: 20),
          // 心情日历
          _buildMoodCalendar(history),
          const SizedBox(height: 20),
          // 心情统计
          _buildMoodStats(history),
        ],
      ),
    );
  }

  Widget _buildCurrentMood(Mood mood) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(mood.emoji, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 12),
            Text(
              '当前心情：${mood.label}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '心情指数：${(mood.score * 100).round()}%',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodSelector(WidgetRef ref) {
    final moods = [
      (MoodType.happy, '😊', '开心'),
      (MoodType.calm, '😌', '平静'),
      (MoodType.sad, '😢', '忧郁'),
      (MoodType.sleepy, '😴', '困倦'),
      (MoodType.sweet, '😍', '甜蜜'),
      (MoodType.thinking, '🤔', '思考'),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('记录此刻心情', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: moods.map((m) {
                return GestureDetector(
                  onTap: () => ref.read(moodProvider.notifier).setMood(m.$1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                    ),
                    child: Text('${m.$2} ${m.$3}', style: const TextStyle(fontSize: 14)),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodCalendar(List<Map<String, dynamic>> history) {
    // 最近7天的心情
    final now = DateTime.now();
    final days = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('最近7天', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: days.map((day) {
                final dateStr = day.toIso8601String().substring(0, 10);
                final record = history.firstWhere(
                  (h) => h['date'] == dateStr,
                  orElse: () => {},
                );
                final moodType = record.isNotEmpty ? MoodType.values[record['type'] ?? 2] : null;

                return Column(
                  children: [
                    Text(
                      '${day.day}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: day.day == now.day ? AppColors.accent : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: moodType != null ? AppColors.accent.withOpacity(0.1) : AppColors.background,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: moodType != null
                            ? Text(_getMoodEmoji(moodType), style: const TextStyle(fontSize: 18))
                            : Icon(Icons.remove, color: AppColors.textLight, size: 16),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodStats(List<Map<String, dynamic>> history) {
    if (history.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text('还没有心情记录', style: TextStyle(color: AppColors.textSecondary)),
          ),
        ),
      );
    }

    // 统计各心情出现次数
    final counts = <String, int>{};
    for (final h in history) {
      final type = MoodType.values[h['type'] ?? 2];
      final label = _getMoodLabel(type);
      counts[label] = (counts[label] ?? 0) + 1;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('心情统计', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...counts.entries.map((e) {
              final total = history.length;
              final percent = (e.value / total * 100).round();
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(e.key, style: const TextStyle(fontSize: 14)),
                        Text('$percent%', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: e.value / total,
                      backgroundColor: AppColors.background,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _getMoodEmoji(MoodType type) {
    switch (type) {
      case MoodType.happy: return '😊';
      case MoodType.calm: return '😌';
      case MoodType.sad: return '😢';
      case MoodType.sleepy: return '😴';
      case MoodType.sweet: return '😍';
      case MoodType.thinking: return '🤔';
    }
  }

  String _getMoodLabel(MoodType type) {
    switch (type) {
      case MoodType.happy: return '😊 开心';
      case MoodType.calm: return '😌 平静';
      case MoodType.sad: return '😢 忧郁';
      case MoodType.sleepy: return '😴 困倦';
      case MoodType.sweet: return '😍 甜蜜';
      case MoodType.thinking: return '🤔 思考';
    }
  }
}
