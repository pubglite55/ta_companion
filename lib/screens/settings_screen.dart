import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/colors.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection('AI 伴侣设置', [
            _buildSettingRow('名字', settings.companionName),
            _buildSettingRow('性格', settings.companionPersonality),
          ]),
          const SizedBox(height: 16),
          _buildSection('API 配置', [
            _buildSettingRow('AI 服务', settings.aiProvider ?? '未配置'),
            _buildApiKeyRow('API Key', settings.aiApiKey),
          ]),
          const SizedBox(height: 16),
          _buildSection('通知设置', [
            _buildSwitchRow('早安问候', settings.morningGreeting, (value) {
              ref.read(settingsProvider.notifier).updateSettings(
                settings.copyWith(morningGreeting: value),
              );
            }),
            _buildSwitchRow('午间分享', settings.noonShare, (value) {
              ref.read(settingsProvider.notifier).updateSettings(
                settings.copyWith(noonShare: value),
              );
            }),
            _buildSwitchRow('晚间聊天', settings.eveningChat, (value) {
              ref.read(settingsProvider.notifier).updateSettings(
                settings.copyWith(eveningChat: value),
              );
            }),
            _buildSwitchRow('睡前关怀', settings.nightCare, (value) {
              ref.read(settingsProvider.notifier).updateSettings(
                settings.copyWith(nightCare: value),
              );
            }),
          ]),
          const SizedBox(height: 16),
          _buildSection('关于', [
            _buildSettingRow('版本', '1.0.0'),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSettingRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textPrimary)),
          Text(value, style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildApiKeyRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textPrimary)),
          Text(
            value != null ? '••••••' : '未配置',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textPrimary)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.accent,
          ),
        ],
      ),
    );
  }
}
