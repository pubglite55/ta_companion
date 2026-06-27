import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/colors.dart';
import '../providers/settings_provider.dart';
import '../services/notification_service.dart';

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
            _buildSettingRow('名字', settings.companionName, () {
              _showEditDialog(context, '修改名字', settings.companionName, (value) {
                ref.read(settingsProvider.notifier).updateSettings(
                  settings.copyWith(companionName: value),
                );
              });
            }),
            _buildSettingRow('性格', settings.companionPersonality, () {
              _showEditDialog(context, '修改性格', settings.companionPersonality, (value) {
                ref.read(settingsProvider.notifier).updateSettings(
                  settings.copyWith(companionPersonality: value),
                );
              });
            }),
          ]),
          const SizedBox(height: 16),
          _buildSection('AI 配置', [
            _buildSettingRow('AI 服务', settings.aiProvider ?? '未配置', () {
              _showProviderDialog(context, ref, settings);
            }),
            _buildSettingRow('模型', settings.aiModel ?? '未配置', () {
              _showEditDialog(context, '输入模型名称', settings.aiModel ?? '', (value) {
                ref.read(settingsProvider.notifier).updateSettings(
                  settings.copyWith(aiModel: value),
                );
              });
            }),
            _buildApiKeyRow('API Key', settings.aiApiKey, () {
              _showEditDialog(context, '输入 API Key', settings.aiApiKey ?? '', (value) {
                ref.read(settingsProvider.notifier).updateSettings(
                  settings.copyWith(aiApiKey: value),
                );
              }, isPassword: true);
            }),
          ]),
          const SizedBox(height: 16),
          _buildSection('外观设置', [
            _buildSwitchRow('深色模式', settings.isDarkMode, (value) {
              ref.read(settingsProvider.notifier).updateSettings(
                settings.copyWith(isDarkMode: value),
              );
            }),
          ]),
          const SizedBox(height: 16),
          _buildSection('提示词设置', [
            ListTile(
              leading: Icon(
                Icons.edit_note,
                color: settings.customPrompt != null ? AppColors.accent : AppColors.textSecondary,
              ),
              title: const Text('自定义提示词'),
              subtitle: Text(
                settings.customPrompt != null ? '已设置（点击编辑）' : '未设置（使用默认）',
                style: TextStyle(
                  color: settings.customPrompt != null ? AppColors.accent : AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showPromptEditor(context, ref, settings),
            ),
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
            const Divider(),
            ListTile(
              leading: const Icon(Icons.send, color: AppColors.accent),
              title: const Text('发送测试通知'),
              subtitle: const Text('立即收到一条测试通知'),
              onTap: () async {
                final notificationService = NotificationService();
                await notificationService.sendTestNotification();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('测试通知已发送！')),
                  );
                }
              },
            ),
          ]),
          const SizedBox(height: 16),
          _buildSection('关于', [
            _buildSettingRow('版本', '1.0.0', null),
          ]),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, String title, String currentValue, ValueChanged<String> onSave, {bool isPassword = false}) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: '请输入...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showPromptEditor(BuildContext context, WidgetRef ref, AppSettings settings) {
    final controller = TextEditingController(text: settings.customPrompt ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('自定义提示词'),
        content: SizedBox(
          width: double.maxFinite,
          child: TextField(
            controller: controller,
            maxLines: 10,
            decoration: InputDecoration(
              hintText: '在这里写你想要的提示词...\n\n例如：\n你是一个活泼可爱的女朋友，说话很甜，喜欢撒娇...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(settingsProvider.notifier).updateSettings(
                settings.copyWith(customPrompt: null),
              );
              Navigator.pop(context);
            },
            child: const Text('恢复默认'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              ref.read(settingsProvider.notifier).updateSettings(
                settings.copyWith(customPrompt: controller.text.isEmpty ? null : controller.text),
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('提示词已保存')),
              );
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showProviderDialog(BuildContext context, WidgetRef ref, AppSettings settings) {
    final nameController = TextEditingController(text: settings.aiProvider);
    final urlController = TextEditingController(text: settings.aiBaseUrl ?? '');
    final modelController = TextEditingController(text: settings.aiModel ?? '');
    String selectedProvider = settings.aiProvider ?? '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('AI 服务配置'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('选择预设', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildProviderChipOption('openai', 'OpenAI', selectedProvider, (value) {
                      setDialogState(() {
                        selectedProvider = value;
                        nameController.text = value;
                        modelController.text = 'gpt-3.5-turbo';
                        urlController.text = '';
                      });
                    }),
                    _buildProviderChipOption('claude', 'Claude', selectedProvider, (value) {
                      setDialogState(() {
                        selectedProvider = value;
                        nameController.text = value;
                        modelController.text = 'claude-3-haiku-20240307';
                        urlController.text = '';
                      });
                    }),
                    _buildProviderChipOption('deepseek', 'DeepSeek', selectedProvider, (value) {
                      setDialogState(() {
                        selectedProvider = value;
                        nameController.text = value;
                        modelController.text = 'deepseek-chat';
                        urlController.text = '';
                      });
                    }),
                    _buildProviderChipOption('zhipu', '智谱GLM', selectedProvider, (value) {
                      setDialogState(() {
                        selectedProvider = value;
                        nameController.text = value;
                        modelController.text = 'glm-4-flash';
                        urlController.text = '';
                      });
                    }),
                    _buildProviderChipOption('custom', '自定义', selectedProvider, (value) {
                      setDialogState(() {
                        selectedProvider = value;
                        nameController.text = '';
                        modelController.text = '';
                        urlController.text = '';
                      });
                    }),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: '服务名称',
                    hintText: '如 openai',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    isDense: true,
                  ),
                  onChanged: (value) => setDialogState(() => selectedProvider = value),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: modelController,
                  decoration: InputDecoration(
                    labelText: '模型名称',
                    hintText: '如 glm-4-flash',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: urlController,
                  decoration: InputDecoration(
                    labelText: 'API Base URL (可选)',
                    hintText: '自定义服务时填写',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    isDense: true,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                ref.read(settingsProvider.notifier).updateSettings(
                  settings.copyWith(
                    aiProvider: selectedProvider.isEmpty ? nameController.text : selectedProvider,
                    aiModel: modelController.text.isEmpty ? null : modelController.text,
                    aiBaseUrl: urlController.text.isEmpty ? null : urlController.text,
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderChipOption(String value, String label, String selectedValue, ValueChanged<String> onChanged) {
    final isSelected = selectedValue == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          onChanged(value);
        }
      },
      selectedColor: AppColors.accent,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
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

  Widget _buildSettingRow(String label, String value, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: AppColors.textPrimary)),
            Row(
              children: [
                Text(value, style: const TextStyle(color: AppColors.textSecondary)),
                if (onTap != null) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApiKeyRow(String label, String? value, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: AppColors.textPrimary)),
            Row(
              children: [
                Text(
                  value != null ? '••••••' : '未配置',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                if (onTap != null) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
                ],
              ],
            ),
          ],
        ),
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
