import 'mood.dart';

class Companion {
  final String name;
  final String personality;
  final String? avatarUrl;
  final Mood currentMood;
  final String? currentSong;
  final String? currentQuote;
  final DateTime lastInteraction;

  const Companion({
    required this.name,
    required this.personality,
    this.avatarUrl,
    required this.currentMood,
    this.currentSong,
    this.currentQuote,
    required this.lastInteraction,
  });

  Companion copyWith({
    String? name,
    String? personality,
    String? avatarUrl,
    Mood? currentMood,
    String? currentSong,
    String? currentQuote,
    DateTime? lastInteraction,
  }) {
    return Companion(
      name: name ?? this.name,
      personality: personality ?? this.personality,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      currentMood: currentMood ?? this.currentMood,
      currentSong: currentSong ?? this.currentSong,
      currentQuote: currentQuote ?? this.currentQuote,
      lastInteraction: lastInteraction ?? this.lastInteraction,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'personality': personality,
    'avatarUrl': avatarUrl,
    'currentMood': currentMood.toJson(),
    'currentSong': currentSong,
    'currentQuote': currentQuote,
    'lastInteraction': lastInteraction.toIso8601String(),
  };

  factory Companion.fromJson(Map<String, dynamic> json) => Companion(
    name: json['name'],
    personality: json['personality'],
    avatarUrl: json['avatarUrl'],
    currentMood: Mood.fromJson(json['currentMood']),
    currentSong: json['currentSong'],
    currentQuote: json['currentQuote'],
    lastInteraction: DateTime.parse(json['lastInteraction']),
  );
}
