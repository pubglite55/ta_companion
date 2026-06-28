import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/colors.dart';
import '../models/intimacy.dart';
import '../models/rewards.dart';
import '../providers/intimacy_provider.dart';

class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intimacy = ref.watch(intimacyProvider);
    final allRewards = RewardSystem.getRewardsForLevel(intimacy.level);
    final unlocked = allRewards.where((r) => r.isUnlocked).toList();
    final locked = allRewards.where((r) => !r.isUnlocked).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('亲密奖励'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildLevelCard(intimacy),
          const SizedBox(height: 20),
          if (unlocked.isNotEmpty) ...[
            _buildSectionTitle('已解锁', unlocked.length),
            const SizedBox(height: 12),
            ...unlocked.map((r) => _buildRewardCard(r, true)),
            const SizedBox(height: 20),
          ],
          if (locked.isNotEmpty) ...[
            _buildSectionTitle('未解锁', locked.length),
            const SizedBox(height: 12),
            ...locked.map((r) => _buildRewardCard(r, false)),
          ],
        ],
      ),
    );
  }

  Widget _buildLevelCard(Intimacy intimacy) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(intimacy.levelEmoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              intimacy.levelLabel,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: intimacy.progress,
              backgroundColor: AppColors.background,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Text(
              '${intimacy.score}/100',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: TextStyle(fontSize: 12, color: AppColors.accent),
          ),
        ),
      ],
    );
  }

  Widget _buildRewardCard(Reward reward, bool isUnlocked) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isUnlocked
                    ? AppColors.accent.withOpacity(0.1)
                    : AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  reward.emoji,
                  style: TextStyle(
                    fontSize: 24,
                    color: isUnlocked ? null : AppColors.textLight,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reward.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isUnlocked ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reward.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: isUnlocked ? AppColors.textSecondary : AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
            if (isUnlocked)
              Icon(Icons.check_circle, color: AppColors.accent)
            else
              Icon(Icons.lock_outline, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }
}
