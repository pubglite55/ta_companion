import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

class AppSettings {
  final String companionName;
  final String companionPersonality;
  final String? aiProvider;
  final String? aiApiKey;
  final String? aiBaseUrl;
  final String? aiModel;
  final String? customPrompt;
  final bool isDarkMode;
  final bool morningGreeting;
  final bool noonShare;
  final bool eveningChat;
  final bool nightCare;
  final bool autoTts;

  const AppSettings({
    this.companionName = 'TA',
    this.companionPersonality = '温柔亲密',
    this.aiProvider,
    this.aiApiKey,
    this.aiBaseUrl,
    this.aiModel,
    this.customPrompt,
    this.isDarkMode = false,
    this.morningGreeting = true,
    this.noonShare = true,
    this.eveningChat = true,
    this.nightCare = true,
    this.autoTts = false,
  });

  AppSettings copyWith({
    String? companionName,
    String? companionPersonality,
    String? aiProvider,
    String? aiApiKey,
    String? aiBaseUrl,
    String? aiModel,
    String? customPrompt,
    bool? isDarkMode,
    bool? morningGreeting,
    bool? noonShare,
    bool? eveningChat,
    bool? nightCare,
    bool? autoTts,
  }) {
    return AppSettings(
      companionName: companionName ?? this.companionName,
      companionPersonality: companionPersonality ?? this.companionPersonality,
      aiProvider: aiProvider ?? this.aiProvider,
      aiApiKey: aiApiKey ?? this.aiApiKey,
      aiBaseUrl: aiBaseUrl ?? this.aiBaseUrl,
      aiModel: aiModel ?? this.aiModel,
      customPrompt: customPrompt ?? this.customPrompt,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      morningGreeting: morningGreeting ?? this.morningGreeting,
      noonShare: noonShare ?? this.noonShare,
      eveningChat: eveningChat ?? this.eveningChat,
      nightCare: nightCare ?? this.nightCare,
      autoTts: autoTts ?? this.autoTts,
    );
  }
}

class SettingsProvider extends StateNotifier<AppSettings> {
  SettingsProvider() : super(const AppSettings()) {
    _loadSettings();
  }

  Box? _box;

  void _loadSettings() {
    try {
      _box = Hive.box('settings');
      state = AppSettings(
        companionName: _box!.get('companionName', defaultValue: 'TA'),
        companionPersonality: _box!.get('companionPersonality', defaultValue: '温柔亲密'),
        aiProvider: _box!.get('aiProvider'),
        aiApiKey: _box!.get('aiApiKey'),
        aiBaseUrl: _box!.get('aiBaseUrl'),
        aiModel: _box!.get('aiModel'),
        customPrompt: _box!.get('customPrompt'),
        isDarkMode: _box!.get('isDarkMode', defaultValue: false),
        morningGreeting: _box!.get('morningGreeting', defaultValue: true),
        noonShare: _box!.get('noonShare', defaultValue: true),
        eveningChat: _box!.get('eveningChat', defaultValue: true),
        nightCare: _box!.get('nightCare', defaultValue: true),
        autoTts: _box!.get('autoTts', defaultValue: false),
      );
    } catch (e) {
      print('[Settings] Load error: $e');
    }
  }

  void updateSettings(AppSettings newSettings) {
    state = newSettings;
    _saveSettings();
  }

  void _saveSettings() {
    try {
      _box?.put('companionName', state.companionName);
      _box?.put('companionPersonality', state.companionPersonality);
      _box?.put('aiProvider', state.aiProvider);
      _box?.put('aiApiKey', state.aiApiKey);
      _box?.put('aiBaseUrl', state.aiBaseUrl);
      _box?.put('aiModel', state.aiModel);
      _box?.put('customPrompt', state.customPrompt);
      _box?.put('isDarkMode', state.isDarkMode);
      _box?.put('morningGreeting', state.morningGreeting);
      _box?.put('noonShare', state.noonShare);
      _box?.put('eveningChat', state.eveningChat);
      _box?.put('nightCare', state.nightCare);
      _box?.put('autoTts', state.autoTts);
    } catch (e) {
      print('[Settings] Save error: $e');
    }
  }
}

final settingsProvider = StateNotifierProvider<SettingsProvider, AppSettings>((ref) {
  return SettingsProvider();
});
