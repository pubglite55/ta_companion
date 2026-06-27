import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

class AppSettings {
  final String companionName;
  final String companionPersonality;
  final String? aiProvider;
  final String? aiApiKey;
  final String? weatherApiKey;
  final String? musicApiKey;
  final String? newsApiKey;
  final bool morningGreeting;
  final bool noonShare;
  final bool eveningChat;
  final bool nightCare;

  const AppSettings({
    this.companionName = 'TA',
    this.companionPersonality = '温柔亲密',
    this.aiProvider,
    this.aiApiKey,
    this.weatherApiKey,
    this.musicApiKey,
    this.newsApiKey,
    this.morningGreeting = true,
    this.noonShare = true,
    this.eveningChat = true,
    this.nightCare = true,
  });

  AppSettings copyWith({
    String? companionName,
    String? companionPersonality,
    String? aiProvider,
    String? aiApiKey,
    String? weatherApiKey,
    String? musicApiKey,
    String? newsApiKey,
    bool? morningGreeting,
    bool? noonShare,
    bool? eveningChat,
    bool? nightCare,
  }) {
    return AppSettings(
      companionName: companionName ?? this.companionName,
      companionPersonality: companionPersonality ?? this.companionPersonality,
      aiProvider: aiProvider ?? this.aiProvider,
      aiApiKey: aiApiKey ?? this.aiApiKey,
      weatherApiKey: weatherApiKey ?? this.weatherApiKey,
      musicApiKey: musicApiKey ?? this.musicApiKey,
      newsApiKey: newsApiKey ?? this.newsApiKey,
      morningGreeting: morningGreeting ?? this.morningGreeting,
      noonShare: noonShare ?? this.noonShare,
      eveningChat: eveningChat ?? this.eveningChat,
      nightCare: nightCare ?? this.nightCare,
    );
  }
}

class SettingsProvider extends StateNotifier<AppSettings> {
  SettingsProvider() : super(const AppSettings()) {
    _loadSettings();
  }

  final Box _box = Hive.box('settings');

  void _loadSettings() {
    state = AppSettings(
      companionName: _box.get('companionName', defaultValue: 'TA'),
      companionPersonality: _box.get('companionPersonality', defaultValue: '温柔亲密'),
      aiProvider: _box.get('aiProvider'),
      aiApiKey: _box.get('aiApiKey'),
      weatherApiKey: _box.get('weatherApiKey'),
      musicApiKey: _box.get('musicApiKey'),
      newsApiKey: _box.get('newsApiKey'),
      morningGreeting: _box.get('morningGreeting', defaultValue: true),
      noonShare: _box.get('noonShare', defaultValue: true),
      eveningChat: _box.get('eveningChat', defaultValue: true),
      nightCare: _box.get('nightCare', defaultValue: true),
    );
  }

  void updateSettings(AppSettings newSettings) {
    state = newSettings;
    _saveSettings();
  }

  void _saveSettings() {
    _box.put('companionName', state.companionName);
    _box.put('companionPersonality', state.companionPersonality);
    _box.put('aiProvider', state.aiProvider);
    _box.put('aiApiKey', state.aiApiKey);
    _box.put('weatherApiKey', state.weatherApiKey);
    _box.put('musicApiKey', state.musicApiKey);
    _box.put('newsApiKey', state.newsApiKey);
    _box.put('morningGreeting', state.morningGreeting);
    _box.put('noonShare', state.noonShare);
    _box.put('eveningChat', state.eveningChat);
    _box.put('nightCare', state.nightCare);
  }
}

final settingsProvider = StateNotifierProvider<SettingsProvider, AppSettings>((ref) {
  return SettingsProvider();
});
