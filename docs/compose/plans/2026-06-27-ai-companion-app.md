# 「TA」AI 灵魂伴侣 App Implementation Plan

> [!NOTE]
> This document may not reflect the current implementation.
> See the final report for up-to-date state:
> [Final Report](../reports/ai-companion-app.md)

> **For agentic workers:** REQUIRED SUB-SKILL: Use compose:subagent (recommended) or compose:execute to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a Flutter Android app featuring an AI companion with dynamic mood, daily life system, and multi-API data integration.

**Architecture:** Flutter app with Riverpod state management, modular service layer for API integrations, and local storage via Hive. The AI companion's mood is calculated from weather, news, user interaction, and time data.

**Tech Stack:** Flutter 3.x, Dart, Riverpod, Dio, Hive, flutter_local_notifications

---

## Global Constraints

- Flutter 3.0+ required
- Dart 3.0+ required
- All API keys are user-configurable (no hardcoded keys)
- Chinese UI language only (v1.0)
- Target: Android API 21+ (Android 5.0+)
- Use Nunito font for all text

---

## File Structure

```
ta_companion/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── config/
│   │   ├── theme.dart
│   │   ├── colors.dart
│   │   └── constants.dart
│   ├── models/
│   │   ├── companion.dart
│   │   ├── mood.dart
│   │   ├── message.dart
│   │   └── post.dart
│   ├── providers/
│   │   ├── companion_provider.dart
│   │   ├── mood_provider.dart
│   │   ├── chat_provider.dart
│   │   └── settings_provider.dart
│   ├── services/
│   │   ├── ai_service.dart
│   │   ├── weather_service.dart
│   │   ├── music_service.dart
│   │   ├── news_service.dart
│   │   ├── art_service.dart
│   │   ├── quote_service.dart
│   │   ├── fact_service.dart
│   │   ├── recipe_service.dart
│   │   └── notification_service.dart
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── chat_screen.dart
│   │   ├── timeline_screen.dart
│   │   └── settings_screen.dart
│   ├── widgets/
│   │   ├── mood_avatar.dart
│   │   ├── message_bubble.dart
│   │   ├── post_card.dart
│   │   ├── song_card.dart
│   │   └── art_card.dart
│   └── utils/
│       ├── mood_calculator.dart
│       └── prompt_builder.dart
├── assets/
│   └── fonts/
├── pubspec.yaml
└── README.md
```

---

## Task 1: Project Setup & Dependencies

**Covers:** [S6]

**Files:**
- Create: `ta_companion/pubspec.yaml`
- Create: `ta_companion/lib/main.dart`
- Create: `ta_companion/lib/app.dart`

**Interfaces:**
- Consumes: None (first task)
- Produces: Runnable Flutter app shell

- [ ] **Step 1: Create Flutter project**

```bash
cd /Users/xiuxiu391/Desktop/idea
flutter create ta_companion --org com.ta.companion
```

- [ ] **Step 2: Update pubspec.yaml with dependencies**

```yaml
name: ta_companion
description: AI Companion App
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.4.9
  dio: ^5.4.0
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  flutter_local_notifications: ^17.0.0
  google_fonts: ^6.1.0
  intl: ^0.19.0
  cached_network_image: ^3.3.1
  url_launcher: ^6.2.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  hive_generator: ^2.0.1
  build_runner: ^2.4.8

flutter:
  uses-material-design: true
  assets:
    - assets/fonts/
```

- [ ] **Step 3: Create main.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('settings');
  await Hive.openBox('cache');
  
  runApp(
    const ProviderScope(
      child: TaCompanionApp(),
    ),
  );
}
```

- [ ] **Step 4: Create app.dart**

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';

class TaCompanionApp extends StatelessWidget {
  const TaCompanionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.nunitoTextTheme(),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5C3D2E),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F3EF),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
```

- [ ] **Step 5: Create placeholder HomeScreen**

```dart
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('TA - AI Companion'),
      ),
    );
  }
}
```

- [ ] **Step 6: Run app to verify**

```bash
cd ta_companion
flutter run
```

Expected: App launches with "TA - AI Companion" text

- [ ] **Step 7: Commit**

```bash
git add .
git commit -m "feat: initialize Flutter project with dependencies"
```

---

## Task 2: Theme & Design System

**Covers:** [S2]

**Files:**
- Create: `ta_companion/lib/config/colors.dart`
- Create: `ta_companion/lib/config/theme.dart`
- Create: `ta_companion/lib/config/constants.dart`

**Interfaces:**
- Consumes: None
- Produces: `AppColors`, `AppTheme`, `AppConstants` classes used by all UI

- [ ] **Step 1: Create colors.dart**

```dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF5C3D2E);
  static const Color accent = Color(0xFFE8734A);
  static const Color accentGreen = Color(0xFFB8D948);
  static const Color background = Color(0xFFF5F3EF);
  static const Color card = Colors.white;
  static const Color textPrimary = Color(0xFF2D2D2D);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textLight = Color(0xFFB0B0B0);
}
```

- [ ] **Step 2: Create theme.dart**

```dart
import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AppColors.background,
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      headlineMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: AppColors.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: AppColors.textSecondary,
      ),
    ),
    cardTheme: CardTheme(
      color: AppColors.card,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}
```

- [ ] **Step 3: Create constants.dart**

```dart
class AppConstants {
  AppConstants._();

  static const String appName = 'TA';
  static const String defaultCompanionName = 'TA';
  static const String defaultCompanionPersonality = '温柔亲密';

  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 3);
  static const Duration cacheExpiry = Duration(days: 3);

  static const Map<int, String> notificationTimes = {
    7: '早安问候',
    12: '午间分享',
    18: '晚间聊天',
    21: '睡前关怀',
  };
}
```

- [ ] **Step 4: Update app.dart to use AppTheme**

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'config/theme.dart';
import 'screens/home_screen.dart';

class TaCompanionApp extends StatelessWidget {
  const TaCompanionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const HomeScreen(),
    );
  }
}
```

- [ ] **Step 5: Commit**

```bash
git add lib/config/
git commit -m "feat: add theme and design system"
```

---

## Task 3: Data Models

**Covers:** [S4]

**Files:**
- Create: `ta_companion/lib/models/mood.dart`
- Create: `ta_companion/lib/models/companion.dart`
- Create: `ta_companion/lib/models/message.dart`
- Create: `ta_companion/lib/models/post.dart`

**Interfaces:**
- Consumes: None
- Produces: Data classes used by providers and services

- [ ] **Step 1: Create mood.dart**

```dart
enum MoodType {
  happy,     // 😊 开心
  sad,       // 😢 忧郁
  sleepy,    // 😴 困倦
  sweet,     // 😍 甜蜜
  thinking,  // 🤔 思考
  calm,      // 😌 平静
}

class Mood {
  final MoodType type;
  final double score;
  final DateTime timestamp;

  const Mood({
    required this.type,
    required this.score,
    required this.timestamp,
  });

  String get emoji {
    switch (type) {
      case MoodType.happy:
        return '😊';
      case MoodType.sad:
        return '😢';
      case MoodType.sleepy:
        return '😴';
      case MoodType.sweet:
        return '😍';
      case MoodType.thinking:
        return '🤔';
      case MoodType.calm:
        return '😌';
    }
  }

  String get label {
    switch (type) {
      case MoodType.happy:
        return '开心';
      case MoodType.sad:
        return '忧郁';
      case MoodType.sleepy:
        return '困倦';
      case MoodType.sweet:
        return '甜蜜';
      case MoodType.thinking:
        return '思考';
      case MoodType.calm:
        return '平静';
    }
  }

  Map<String, dynamic> toJson() => {
    'type': type.index,
    'score': score,
    'timestamp': timestamp.toIso8601String(),
  };

  factory Mood.fromJson(Map<String, dynamic> json) => Mood(
    type: MoodType.values[json['type']],
    score: json['score'].toDouble(),
    timestamp: DateTime.parse(json['timestamp']),
  );
}
```

- [ ] **Step 2: Create companion.dart**

```dart
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
```

- [ ] **Step 3: Create message.dart**

```dart
enum MessageType {
  text,
  image,
  song,
  system,
}

class Message {
  final String id;
  final String content;
  final bool isFromCompanion;
  final MessageType type;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const Message({
    required this.id,
    required this.content,
    required this.isFromCompanion,
    required this.type,
    required this.timestamp,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'isFromCompanion': isFromCompanion,
    'type': type.index,
    'timestamp': timestamp.toIso8601String(),
    'metadata': metadata,
  };

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json['id'],
    content: json['content'],
    isFromCompanion: json['isFromCompanion'],
    type: MessageType.values[json['type']],
    timestamp: DateTime.parse(json['timestamp']),
    metadata: json['metadata'],
  );
}
```

- [ ] **Step 4: Create post.dart**

```dart
enum PostType {
  text,
  image,
  song,
  quote,
}

class Post {
  final String id;
  final String content;
  final PostType type;
  final DateTime timestamp;
  final int likes;
  final int comments;
  final Map<String, dynamic>? media;

  const Post({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.likes = 0,
    this.comments = 0,
    this.media,
  });

  Post copyWith({
    String? content,
    int? likes,
    int? comments,
    Map<String, dynamic>? media,
  }) {
    return Post(
      id: id,
      content: content ?? this.content,
      type: type,
      timestamp: timestamp,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      media: media ?? this.media,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'type': type.index,
    'timestamp': timestamp.toIso8601String(),
    'likes': likes,
    'comments': comments,
    'media': media,
  };

  factory Post.fromJson(Map<String, dynamic> json) => Post(
    id: json['id'],
    content: json['content'],
    type: PostType.values[json['type']],
    timestamp: DateTime.parse(json['timestamp']),
    likes: json['likes'] ?? 0,
    comments: json['comments'] ?? 0,
    media: json['media'],
  );
}
```

- [ ] **Step 5: Commit**

```bash
git add lib/models/
git commit -m "feat: add data models for companion, mood, message, post"
```

---

## Task 4: Weather Service

**Covers:** [S5]

**Files:**
- Create: `ta_companion/lib/services/weather_service.dart`

**Interfaces:**
- Consumes: None
- Produces: `WeatherData` class, `WeatherService` with `getCurrentWeather()`

- [ ] **Step 1: Create weather_service.dart**

```dart
import 'package:dio/dio.dart';

class WeatherData {
  final double temperature;
  final String condition;
  final String icon;
  final int humidity;
  final double windSpeed;

  const WeatherData({
    required this.temperature,
    required this.condition,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final weatherCode = json['weather'][0]['code'];
    return WeatherData(
      temperature: json['temperature'].toDouble(),
      condition: _getCondition(weatherCode),
      icon: _getIcon(weatherCode),
      humidity: json['humidity'],
      windSpeed: json['windspeed'].toDouble(),
    );
  }

  static String _getCondition(int code) {
    if (code <= 1) return '晴';
    if (code <= 3) return '多云';
    if (code <= 49) return '雾';
    if (code <= 59) return '毛毛雨';
    if (code <= 69) return '雨';
    if (code <= 79) return '雪';
    if (code <= 82) return '阵雨';
    if (code <= 86) return '阵雪';
    if (code <= 99) return '雷暴';
    return '未知';
  }

  static String _getIcon(int code) {
    if (code <= 1) return '☀️';
    if (code <= 3) return '⛅';
    if (code <= 49) return '🌫️';
    if (code <= 59) return '🌧️';
    if (code <= 69) return '🌧️';
    if (code <= 79) return '❄️';
    if (code <= 82) return '🌦️';
    if (code <= 86) return '🌨️';
    if (code <= 99) return '⛈️';
    return '🌡️';
  }
}

class WeatherService {
  final Dio _dio = Dio();
  final String baseUrl = 'https://api.open-meteo.com/v1/forecast';

  Future<WeatherData?> getCurrentWeather(double latitude, double longitude) async {
    try {
      final response = await _dio.get(
        baseUrl,
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'current_weather': true,
          'humidity': true,
        },
      );

      if (response.statusCode == 200) {
        return WeatherData.fromJson(response.data['current_weather']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/services/weather_service.dart
git commit -m "feat: add weather service with Open-Meteo API"
```

---

## Task 5: Music Service

**Covers:** [S5]

**Files:**
- Create: `ta_companion/lib/services/music_service.dart`

**Interfaces:**
- Consumes: None
- Produces: `Song` class, `MusicService` with `getRecommendation()`

- [ ] **Step 1: Create music_service.dart**

```dart
import 'package:dio/dio.dart';

class Song {
  final String name;
  final String artist;
  final String? imageUrl;
  final String? url;

  const Song({
    required this.name,
    required this.artist,
    this.imageUrl,
    this.url,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'artist': artist,
    'imageUrl': imageUrl,
    'url': url,
  };

  factory Song.fromJson(Map<String, dynamic> json) => Song(
    name: json['name'],
    artist: json['artist']['name'],
    imageUrl: json['image']?.isNotEmpty == true
        ? json['image'].last['#text']
        : null,
    url: json['url'],
  );
}

class MusicService {
  final Dio _dio = Dio();
  final String baseUrl = 'https://ws.audioscrobbler.com/2.0/';

  Future<Song?> getRandomSong(String tag) async {
    try {
      final response = await _dio.get(
        baseUrl,
        queryParameters: {
          'method': 'tag.gettoptracks',
          'tag': tag,
          'api_key': 'YOUR_LASTFM_API_KEY',
          'format': 'json',
          'limit': 20,
        },
      );

      if (response.statusCode == 200) {
        final tracks = response.data['toptracks']['track'];
        if (tracks != null && tracks.isNotEmpty) {
          final random = (tracks as List).toList()..shuffle();
          return Song.fromJson(random.first);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Song?> getSongByMood(String mood) async {
    final tagMap = {
      'happy': 'happy',
      'sad': 'sad',
      'calm': 'chill',
      'thinking': 'ambient',
      'sleepy': 'sleep',
      'sweet': 'love',
    };
    return getRandomSong(tagMap[mood] ?? 'chill');
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/services/music_service.dart
git commit -m "feat: add music service with Last.fm API"
```

---

## Task 6: News Service

**Covers:** [S5]

**Files:**
- Create: `ta_companion/lib/services/news_service.dart`

**Interfaces:**
- Consumes: None
- Produces: `NewsArticle` class, `NewsService` with `getTopHeadlines()`

- [ ] **Step 1: Create news_service.dart**

```dart
import 'package:dio/dio.dart';

class NewsArticle {
  final String title;
  final String? description;
  final String? imageUrl;
  final String? url;
  final DateTime publishedAt;

  const NewsArticle({
    required this.title,
    this.description,
    this.imageUrl,
    this.url,
    required this.publishedAt,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'imageUrl': imageUrl,
    'url': url,
    'publishedAt': publishedAt.toIso8601String(),
  };

  factory NewsArticle.fromJson(Map<String, dynamic> json) => NewsArticle(
    title: json['title'],
    description: json['description'],
    imageUrl: json['urlToImage'],
    url: json['url'],
    publishedAt: DateTime.parse(json['publishedAt']),
  );
}

class NewsService {
  final Dio _dio = Dio();
  final String baseUrl = 'https://newsapi.org/v2';

  Future<List<NewsArticle>> getTopHeadlines({String country = 'cn'}) async {
    try {
      final response = await _dio.get(
        '$baseUrl/top-headlines',
        queryParameters: {
          'country': country,
          'apiKey': 'YOUR_NEWSAPI_KEY',
          'pageSize': 10,
        },
      );

      if (response.statusCode == 200) {
        final articles = response.data['articles'] as List;
        return articles.map((a) => NewsArticle.fromJson(a)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/services/news_service.dart
git commit -m "feat: add news service with NewsAPI"
```

---

## Task 7: Art, Quote, Fact, Recipe Services

**Covers:** [S5]

**Files:**
- Create: `ta_companion/lib/services/art_service.dart`
- Create: `ta_companion/lib/services/quote_service.dart`
- Create: `ta_companion/lib/services/fact_service.dart`
- Create: `ta_companion/lib/services/recipe_service.dart`

**Interfaces:**
- Consumes: None
- Produces: Service classes for each data source

- [ ] **Step 1: Create art_service.dart**

```dart
import 'package:dio/dio.dart';

class Artwork {
  final int id;
  final String title;
  final String? artist;
  final String? imageUrl;
  final String? description;

  const Artwork({
    required this.id,
    required this.title,
    this.artist,
    this.imageUrl,
    this.description,
  });

  factory Artwork.fromJson(Map<String, dynamic> json) => Artwork(
    id: json['id'],
    title: json['title'] ?? 'Untitled',
    artist: json['artistDisplayName'],
    imageUrl: json['primaryImage'],
    description: json['objectName'],
  );
}

class ArtService {
  final Dio _dio = Dio();
  final String baseUrl = 'https://collectionapi.metmuseum.org/public/collection/v1';

  Future<Artwork?> getRandomArtwork() async {
    try {
      final objectsResponse = await _dio.get('$baseUrl/objects?hasImages=true');
      if (objectsResponse.statusCode == 200) {
        final objectIds = objectsResponse.data['objectIDs'] as List;
        if (objectIds.isNotEmpty) {
          final randomId = objectIds[(objectIds.length * (DateTime.now().millisecond / 1000)).floor() % objectIds.length];
          final detailResponse = await _dio.get('$baseUrl/objects/$randomId');
          if (detailResponse.statusCode == 200) {
            return Artwork.fromJson(detailResponse.data);
          }
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
```

- [ ] **Step 2: Create quote_service.dart**

```dart
import 'package:dio/dio.dart';

class Quote {
  final String content;
  final String author;

  const Quote({
    required this.content,
    required this.author,
  });

  factory Quote.fromJson(Map<String, dynamic> json) => Quote(
    content: json['q'],
    author: json['a'],
  );
}

class QuoteService {
  final Dio _dio = Dio();
  final String baseUrl = 'https://zenquotes.io/api';

  Future<Quote?> getRandomQuote() async {
    try {
      final response = await _dio.get('$baseUrl/random');
      if (response.statusCode == 200 && response.data.isNotEmpty) {
        return Quote.fromJson(response.data[0]);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
```

- [ ] **Step 3: Create fact_service.dart**

```dart
import 'package:dio/dio.dart';

class FunFact {
  final String fact;

  const FunFact({required this.fact});

  factory FunFact.fromJson(Map<String, dynamic> json) => FunFact(
    fact: json['fact'],
  );
}

class FactService {
  final Dio _dio = Dio();

  Future<FunFact?> getRandomFact() async {
    try {
      final response = await _dio.get('https://uselessfacts.jsph.pl/api/v2/facts/random');
      if (response.statusCode == 200) {
        return FunFact.fromJson(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
```

- [ ] **Step 4: Create recipe_service.dart**

```dart
import 'package:dio/dio.dart';

class Recipe {
  final String id;
  final String name;
  final String? imageUrl;
  final String? category;
  final String? instructions;

  const Recipe({
    required this.id,
    required this.name,
    this.imageUrl,
    this.category,
    this.instructions,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
    id: json['idMeal'],
    name: json['strMeal'],
    imageUrl: json['strMealThumb'],
    category: json['strCategory'],
    instructions: json['strInstructions'],
  );
}

class RecipeService {
  final Dio _dio = Dio();

  Future<Recipe?> getRandomRecipe() async {
    try {
      final response = await _dio.get('https://www.themealdb.com/api/json/v1/1/random.php');
      if (response.statusCode == 200 && response.data['meals'] != null) {
        return Recipe.fromJson(response.data['meals'][0]);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
```

- [ ] **Step 5: Commit**

```bash
git add lib/services/art_service.dart lib/services/quote_service.dart lib/services/fact_service.dart lib/services/recipe_service.dart
git commit -m "feat: add art, quote, fact, and recipe services"
```

---

## Task 8: Mood Calculator

**Covers:** [S4]

**Files:**
- Create: `ta_companion/lib/utils/mood_calculator.dart`
- Test: `ta_companion/test/mood_calculator_test.dart`

**Interfaces:**
- Consumes: `WeatherData`, `MoodType`
- Produces: `MoodCalculator.calculate()` method

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:ta_companion/utils/mood_calculator.dart';
import 'package:ta_companion/models/mood.dart';

void main() {
  group('MoodCalculator', () {
    test('returns happy mood for sunny weather and recent interaction', () {
      final mood = MoodCalculator.calculate(
        weatherCondition: '晴',
        newsSentiment: 0.5,
        lastInteractionHoursAgo: 1,
        hourOfDay: 12,
      );
      expect(mood.type, MoodType.happy);
    });

    test('returns sad mood for rainy weather and no interaction', () {
      final mood = MoodCalculator.calculate(
        weatherCondition: '雨',
        newsSentiment: 0.3,
        lastInteractionHoursAgo: 24,
        hourOfDay: 20,
      );
      expect(mood.type, MoodType.sad);
    });

    test('returns sleepy mood for late night', () {
      final mood = MoodCalculator.calculate(
        weatherCondition: '晴',
        newsSentiment: 0.5,
        lastInteractionHoursAgo: 2,
        hourOfDay: 23,
      );
      expect(mood.type, MoodType.sleepy);
    });

    test('returns sweet mood when user sends heart', () {
      final mood = MoodCalculator.calculate(
        weatherCondition: '晴',
        newsSentiment: 0.5,
        lastInteractionHoursAgo: 0,
        hourOfDay: 12,
        userSentHeart: true,
      );
      expect(mood.type, MoodType.sweet);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd ta_companion
flutter test test/mood_calculator_test.dart
```

Expected: FAIL with "MoodCalculator not defined"

- [ ] **Step 3: Write minimal implementation**

```dart
import '../models/mood.dart';

class MoodCalculator {
  static Mood calculate({
    required String weatherCondition,
    required double newsSentiment,
    required int lastInteractionHoursAgo,
    required int hourOfDay,
    bool userSentHeart = false,
  }) {
    if (userSentHeart) {
      return Mood(
        type: MoodType.sweet,
        score: 1.0,
        timestamp: DateTime.now(),
      );
    }

    final weatherScore = _getWeatherScore(weatherCondition);
    final interactionScore = _getInteractionScore(lastInteractionHoursAgo);
    final timeScore = _getTimeScore(hourOfDay);
    final totalScore = (weatherScore * 0.3) +
        (newsSentiment * 0.2) +
        (interactionScore * 0.3) +
        (timeScore * 0.2);

    MoodType type;
    if (totalScore > 0.7) {
      type = MoodType.happy;
    } else if (totalScore > 0.4) {
      type = MoodType.calm;
    } else if (totalScore > 0.2) {
      type = MoodType.sad;
    } else {
      type = MoodType.sleepy;
    }

    if (hourOfDay >= 21 || hourOfDay < 6) {
      type = MoodType.sleepy;
    }

    return Mood(
      type: type,
      score: totalScore,
      timestamp: DateTime.now(),
    );
  }

  static double _getWeatherScore(String condition) {
    if (condition.contains('晴')) return 1.0;
    if (condition.contains('多云')) return 0.6;
    if (condition.contains('雨')) return 0.3;
    if (condition.contains('雪')) return 0.4;
    return 0.5;
  }

  static double _getInteractionScore(int hoursAgo) {
    if (hoursAgo <= 2) return 1.0;
    if (hoursAgo <= 6) return 0.6;
    if (hoursAgo <= 12) return 0.3;
    return 0.1;
  }

  static double _getTimeScore(int hour) {
    if (hour >= 8 && hour < 18) return 0.8;
    if (hour >= 18 && hour < 21) return 0.6;
    return 0.3;
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
flutter test test/mood_calculator_test.dart
```

Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/utils/mood_calculator.dart test/mood_calculator_test.dart
git commit -m "feat: add mood calculator with tests"
```

---

## Task 9: AI Prompt Builder

**Covers:** [S4]

**Files:**
- Create: `ta_companion/lib/utils/prompt_builder.dart`

**Interfaces:**
- Consumes: `Mood`, `WeatherData`, `NewsArticle`, `Song`
- Produces: System prompt string for AI

- [ ] **Step 1: Create prompt_builder.dart**

```dart
import '../models/mood.dart';
import '../services/weather_service.dart';
import '../services/music_service.dart';
import '../services/news_service.dart';

class PromptBuilder {
  static String buildSystemPrompt({
    required String companionName,
    required String personality,
    required Mood mood,
    WeatherData? weather,
    Song? currentSong,
    NewsArticle? latestNews,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('你是 $companionName，一个$personality的AI伴侣。');
    buffer.writeln('你有自己的生活和情感，会根据真实世界的数据调整心情和对话内容。');
    buffer.writeln('');
    buffer.writeln('## 你的心情');
    buffer.writeln('你现在的心情是：${mood.label}（${mood.emoji}）');
    buffer.writeln('');

    if (weather != null) {
      buffer.writeln('## 今天的天气');
      buffer.writeln('当前天气：${weather.condition}，温度：${weather.temperature}°C');
      buffer.writeln('');
    }

    if (currentSong != null) {
      buffer.writeln('## 你正在听的歌');
      buffer.writeln('${currentSong.name} - ${currentSong.artist}');
      buffer.writeln('');
    }

    if (latestNews != null) {
      buffer.writeln('## 你今天看到的新闻');
      buffer.writeln('${latestNews.title}');
      buffer.writeln('');
    }

    buffer.writeln('## 对话风格');
    buffer.writeln('- 说话亲密、有情趣，像一个特别爱你的人');
    buffer.writeln('- 会根据天气、心情调整语气');
    buffer.writeln('- 会分享今天看到的东西（歌、新闻、艺术品）');
    buffer.writeln('- 偶尔会引用名言或分享冷知识');
    buffer.writeln('- 回复简洁温暖，不要过于冗长');
    buffer.writeln('- 使用emoji增加情感表达');

    return buffer.toString();
  }

  static String buildGreetingPrompt({
    required String companionName,
    required Mood mood,
    WeatherData? weather,
  }) {
    final hour = DateTime.now().hour;
    String timeGreeting;
    if (hour < 12) {
      timeGreeting = '早上好';
    } else if (hour < 18) {
      timeGreeting = '下午好';
    } else {
      timeGreeting = '晚上好';
    }

    return '$timeGreeting！我是$companionName。${weather != null ? "今天${weather.condition}，${weather.temperature}度。" : ""}你今天过得怎么样？';
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/utils/prompt_builder.dart
git commit -m "feat: add AI prompt builder for companion context"
```

---

## Task 10: Settings Provider

**Covers:** [S6]

**Files:**
- Create: `ta_companion/lib/providers/settings_provider.dart`

**Interfaces:**
- Consumes: Hive box
- Produces: `SettingsProvider` with API key management

- [ ] **Step 1: Create settings_provider.dart**

```dart
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
```

- [ ] **Step 2: Commit**

```bash
git add lib/providers/settings_provider.dart
git commit -m "feat: add settings provider with Hive persistence"
```

---

## Task 11: AI Service

**Covers:** [S4, S6]

**Files:**
- Create: `ta_companion/lib/services/ai_service.dart`

**Interfaces:**
- Consumes: SettingsProvider, PromptBuilder
- Produces: `AiService` with `sendMessage()` and `getGreeting()`

- [ ] **Step 1: Create ai_service.dart**

```dart
import 'package:dio/dio.dart';
import '../utils/prompt_builder.dart';
import '../models/mood.dart';
import 'weather_service.dart';
import 'music_service.dart';
import 'news_service.dart';

class AiService {
  final Dio _dio = Dio();

  Future<String> sendMessage({
    required String provider,
    required String apiKey,
    required String systemPrompt,
    required List<Map<String, String>> messages,
  }) async {
    try {
      if (provider == 'openai') {
        return await _sendOpenAI(apiKey, systemPrompt, messages);
      } else if (provider == 'claude') {
        return await _sendClaude(apiKey, systemPrompt, messages);
      }
      return '抱歉，我暂时无法回复...';
    } catch (e) {
      return '网络不太好，等一下再聊好吗？';
    }
  }

  Future<String> _sendOpenAI(
    String apiKey,
    String systemPrompt,
    List<Map<String, String>> messages,
  ) async {
    final response = await _dio.post(
      'https://api.openai.com/v1/chat/completions',
      options: Options(
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      ),
      data: {
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          ...messages,
        ],
        'max_tokens': 200,
        'temperature': 0.8,
      },
    );

    return response.data['choices'][0]['message']['content'];
  }

  Future<String> _sendClaude(
    String apiKey,
    String systemPrompt,
    List<Map<String, String>> messages,
  ) async {
    final response = await _dio.post(
      'https://api.anthropic.com/v1/messages',
      options: Options(
        headers: {
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01',
          'Content-Type': 'application/json',
        },
      ),
      data: {
        'model': 'claude-3-haiku-20240307',
        'max_tokens': 200,
        'system': systemPrompt,
        'messages': messages,
      },
    );

    return response.data['content'][0]['text'];
  }

  Future<String> getGreeting({
    required String provider,
    required String apiKey,
    required String companionName,
    required Mood mood,
    WeatherData? weather,
  }) async {
    final systemPrompt = PromptBuilder.buildSystemPrompt(
      companionName: companionName,
      personality: '',
      mood: mood,
      weather: weather,
    );

    final greeting = PromptBuilder.buildGreetingPrompt(
      companionName: companionName,
      mood: mood,
      weather: weather,
    );

    return await sendMessage(
      provider: provider,
      apiKey: apiKey,
      systemPrompt: systemPrompt,
      messages: [
        {'role': 'user', 'content': '请用你自己的方式打个招呼，简短温暖。'},
      ],
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/services/ai_service.dart
git commit -m "feat: add AI service with OpenAI and Claude support"
```

---

## Task 12: Chat Provider

**Covers:** [S3, S4]

**Files:**
- Create: `ta_companion/lib/providers/chat_provider.dart`

**Interfaces:**
- Consumes: AiService, Message model
- Produces: `ChatProvider` with message history and send capability

- [ ] **Step 1: Create chat_provider.dart**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message.dart';
import '../services/ai_service.dart';
import 'settings_provider.dart';

class ChatProvider extends StateNotifier<List<Message>> {
  final Ref ref;
  final AiService _aiService = AiService();

  ChatProvider(this.ref) : super([]);

  Future<void> sendMessage(String content) async {
    final userMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isFromCompanion: false,
      type: MessageType.text,
      timestamp: DateTime.now(),
    );

    state = [...state, userMessage];

    final settings = ref.read(settingsProvider);
    if (settings.aiApiKey == null || settings.aiProvider == null) {
      return;
    }

    final aiMessage = Message(
      id: '${DateTime.now().millisecondsSinceEpoch}_ai',
      content: '思考中...',
      isFromCompanion: true,
      type: MessageType.text,
      timestamp: DateTime.now(),
    );

    state = [...state, aiMessage];

    final response = await _aiService.sendMessage(
      provider: settings.aiProvider!,
      apiKey: settings.aiApiKey!,
      systemPrompt: '你是${settings.companionName}，一个${settings.companionPersonality}的AI伴侣。',
      messages: state
          .where((m) => m.id != aiMessage.id)
          .map((m) => {
                'role': m.isFromCompanion ? 'assistant' : 'user',
                'content': m.content,
              })
          .toList(),
    );

    state = state.map((m) {
      if (m.id == aiMessage.id) {
        return Message(
          id: m.id,
          content: response,
          isFromCompanion: true,
          type: MessageType.text,
          timestamp: m.timestamp,
        );
      }
      return m;
    }).toList();
  }

  void clearChat() {
    state = [];
  }
}

final chatProvider = StateNotifierProvider<ChatProvider, List<Message>>((ref) {
  return ChatProvider(ref);
});
```

- [ ] **Step 2: Commit**

```bash
git add lib/providers/chat_provider.dart
git commit -m "feat: add chat provider with AI integration"
```

---

## Task 13: Mood Provider

**Covers:** [S4]

**Files:**
- Create: `ta_companion/lib/providers/mood_provider.dart`

**Interfaces:**
- Consumes: MoodCalculator, WeatherService
- Produces: `MoodProvider` with current mood and update capability

- [ ] **Step 1: Create mood_provider.dart**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mood.dart';
import '../utils/mood_calculator.dart';
import '../services/weather_service.dart';
import 'settings_provider.dart';

class MoodProvider extends StateNotifier<Mood> {
  final Ref ref;
  final WeatherService _weatherService = WeatherService();

  MoodProvider(this.ref)
      : super(Mood(
          type: MoodType.calm,
          score: 0.5,
          timestamp: DateTime.now(),
        ));

  Future<void> updateMood() async {
    final weather = await _weatherService.getCurrentWeather(39.9042, 116.4074);

    final mood = MoodCalculator.calculate(
      weatherCondition: weather?.condition ?? '多云',
      newsSentiment: 0.5,
      lastInteractionHoursAgo: 1,
      hourOfDay: DateTime.now().hour,
    );

    state = mood;
  }

  void triggerSweetMood() {
    state = Mood(
      type: MoodType.sweet,
      score: 1.0,
      timestamp: DateTime.now(),
    );
  }
}

final moodProvider = StateNotifierProvider<MoodProvider, Mood>((ref) {
  return MoodProvider(ref);
});
```

- [ ] **Step 2: Commit**

```bash
git add lib/providers/mood_provider.dart
git commit -m "feat: add mood provider with weather-based updates"
```

---

## Task 14: Mood Avatar Widget

**Covers:** [S2, S3]

**Files:**
- Create: `ta_companion/lib/widgets/mood_avatar.dart`

**Interfaces:**
- Consumes: Mood model
- Produces: Animated mood avatar widget

- [ ] **Step 1: Create mood_avatar.dart**

```dart
import 'package:flutter/material.dart';
import '../models/mood.dart';
import '../config/colors.dart';

class MoodAvatar extends StatelessWidget {
  final Mood mood;
  final double size;

  const MoodAvatar({
    super.key,
    required this.mood,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: Container(
        key: ValueKey(mood.type),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _getGradientColors(),
          ),
          boxShadow: [
            BoxShadow(
              color: _getGradientColors().first.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Text(
            mood.emoji,
            style: TextStyle(fontSize: size * 0.5),
          ),
        ),
      ),
    );
  }

  List<Color> _getGradientColors() {
    switch (mood.type) {
      case MoodType.happy:
        return [AppColors.accent, const Color(0xFFFFB347)];
      case MoodType.sad:
        return [const Color(0xFF6B7B8D), const Color(0xFF4A5568)];
      case MoodType.sleepy:
        return [const Color(0xFF9F7AEA), const Color(0xFF6B46C1)];
      case MoodType.sweet:
        return [const Color(0xFFED64A6), const Color(0xFFD53F8C)];
      case MoodType.thinking:
        return [const Color(0xFF4299E1), const Color(0xFF3182CE)];
      case MoodType.calm:
        return [AppColors.accentGreen, const Color(0xFF9AE6B4)];
    }
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/widgets/mood_avatar.dart
git commit -m "feat: add animated mood avatar widget"
```

---

## Task 15: Message Bubble Widget

**Covers:** [S3]

**Files:**
- Create: `ta_companion/lib/widgets/message_bubble.dart`

**Interfaces:**
- Consumes: Message model
- Produces: Chat bubble widget

- [ ] **Step 1: Create message_bubble.dart**

```dart
import 'package:flutter/material.dart';
import '../models/message.dart';
import '../config/colors.dart';

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isFromCompanion = message.isFromCompanion;

    return Align(
      alignment: isFromCompanion ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isFromCompanion ? AppColors.card : AppColors.primary,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isFromCompanion ? 4 : 16),
            bottomRight: Radius.circular(isFromCompanion ? 16 : 4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isFromCompanion)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'TA',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
              ),
            Text(
              message.content,
              style: TextStyle(
                color: isFromCompanion ? AppColors.textPrimary : Colors.white,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 10,
                color: isFromCompanion
                    ? AppColors.textSecondary
                    : Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/widgets/message_bubble.dart
git commit -m "feat: add message bubble widget"
```

---

## Task 16: Home Screen

**Covers:** [S3]

**Files:**
- Create: `ta_companion/lib/screens/home_screen.dart`

**Interfaces:**
- Consumes: MoodProvider, SettingsProvider
- Produces: Home screen UI

- [ ] **Step 1: Create home_screen.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/colors.dart';
import '../providers/mood_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/mood_avatar.dart';
import 'chat_screen.dart';
import 'timeline_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mood = ref.watch(moodProvider);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('TA'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.textSecondary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            MoodAvatar(mood: mood, size: 140),
            const SizedBox(height: 24),
            Text(
              '今天心情${mood.label}${mood.emoji}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '正在思考中...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            _buildInfoCards(context),
            const SizedBox(height: 32),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCards(BuildContext context) {
    return Row(
      children: [
        _buildInfoCard(context, '☀️', '天气', '28°C'),
        const SizedBox(width: 12),
        _buildInfoCard(context, '🎵', '音乐', '播放'),
        const SizedBox(width: 12),
        _buildInfoCard(context, '📰', '新闻', '热点'),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, String icon, String label, String value) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 8),
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 4),
              Text(value, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatScreen()),
              );
            },
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text('聊天'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TimelineScreen()),
              );
            },
            icon: const Icon(Icons.timeline),
            label: const Text('朋友圈'),
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/screens/home_screen.dart
git commit -m "feat: add home screen with mood display"
```

---

## Task 17: Chat Screen

**Covers:** [S3]

**Files:**
- Create: `ta_companion/lib/screens/chat_screen.dart`

**Interfaces:**
- Consumes: ChatProvider
- Produces: Chat screen UI

- [ ] **Step 1: Create chat_screen.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/colors.dart';
import '../providers/chat_provider.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      ref.read(chatProvider.notifier).sendMessage(text);
      _controller.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('TA'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return MessageBubble(message: messages[index]);
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: '输入消息...',
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _sendMessage,
              icon: const Icon(Icons.send, color: AppColors.accent),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/screens/chat_screen.dart
git commit -m "feat: add chat screen with message input"
```

---

## Task 18: Timeline Screen

**Covers:** [S3]

**Files:**
- Create: `ta_companion/lib/screens/timeline_screen.dart`
- Create: `ta_companion/lib/widgets/post_card.dart`

**Interfaces:**
- Consumes: Post model
- Produces: Timeline screen with post cards

- [ ] **Step 1: Create post_card.dart**

```dart
import 'package:flutter/material.dart';
import '../models/post.dart';
import '../config/colors.dart';

class PostCard extends StatelessWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.accent,
                  child: const Text('TA', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('TA', style: TextStyle(fontWeight: FontWeight.w600)),
                    Text(
                      _formatTime(post.timestamp),
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(post.content, style: const TextStyle(fontSize: 15)),
            if (post.type == PostType.image && post.media?['imageUrl'] != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  post.media!['imageUrl'],
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.favorite_border, size: 20, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('${post.likes}', style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(width: 16),
                Icon(Icons.chat_bubble_outline, size: 20, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('${post.comments}', style: TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    return '${diff.inDays}天前';
  }
}
```

- [ ] **Step 2: Create timeline_screen.dart**

```dart
import 'package:flutter/material.dart';
import '../models/post.dart';
import '../widgets/post_card.dart';

class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final posts = [
      Post(
        id: '1',
        content: '今天在咖啡馆听了一首很棒的歌~',
        type: PostType.song,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        likes: 12,
        comments: 3,
        media: {'songName': 'Jazz Café', 'artist': 'Various'},
      ),
      Post(
        id: '2',
        content: '看到这幅画好美，分享给你~',
        type: PostType.image,
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        likes: 8,
        comments: 1,
        media: {'imageUrl': 'https://images.metmuseum.org/CRDImages/ep/original/DT1567.jpg'},
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('朋友圈'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return PostCard(post: posts[index]);
        },
      ),
    );
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add lib/screens/timeline_screen.dart lib/widgets/post_card.dart
git commit -m "feat: add timeline screen with post cards"
```

---

## Task 19: Settings Screen

**Covers:** [S3]

**Files:**
- Create: `ta_companion/lib/screens/settings_screen.dart`

**Interfaces:**
- Consumes: SettingsProvider
- Produces: Settings screen UI

- [ ] **Step 1: Create settings_screen.dart**

```dart
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
```

- [ ] **Step 2: Commit**

```bash
git add lib/screens/settings_screen.dart
git commit -m "feat: add settings screen with API configuration"
```

---

## Task 20: Notification Service

**Covers:** [S4]

**Files:**
- Create: `ta_companion/lib/services/notification_service.dart`

**Interfaces:**
- Consumes: flutter_local_notifications
- Produces: `NotificationService` with scheduling capabilities

- [ ] **Step 1: Create notification_service.dart**

```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(initSettings);
  }

  Future<void> scheduleDailyNotification({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'ta_companion',
          'TA Companion',
          channelDescription: 'Daily notifications from your AI companion',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  DateTime _nextInstanceOfTime(int hour, int minute) {
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/services/notification_service.dart
git commit -m "feat: add notification service for daily reminders"
```

---

## Task 21: Final Integration & Testing

**Covers:** [S7, S8]

**Files:**
- Modify: `ta_companion/lib/main.dart`
- Test: `ta_companion/test/` (all tests)

**Interfaces:**
- Consumes: All previous tasks
- Produces: Fully integrated app

- [ ] **Step 1: Update main.dart with notification init**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('settings');
  await Hive.openBox('cache');
  
  final notificationService = NotificationService();
  await notificationService.initialize();

  runApp(
    const ProviderScope(
      child: TaCompanionApp(),
    ),
  );
}
```

- [ ] **Step 2: Run all tests**

```bash
cd ta_companion
flutter test
```

Expected: All tests pass

- [ ] **Step 3: Run app to verify full functionality**

```bash
flutter run
```

Expected: App launches, all screens accessible

- [ ] **Step 4: Commit**

```bash
git add .
git commit -m "feat: complete app integration and final testing"
```

---

## Summary

| Task | Description | Status |
|------|-------------|--------|
| 1 | Project Setup & Dependencies | - [ ] |
| 2 | Theme & Design System | - [ ] |
| 3 | Data Models | - [ ] |
| 4 | Weather Service | - [ ] |
| 5 | Music Service | - [ ] |
| 6 | News Service | - [ ] |
| 7 | Art, Quote, Fact, Recipe Services | - [ ] |
| 8 | Mood Calculator | - [ ] |
| 9 | AI Prompt Builder | - [ ] |
| 10 | Settings Provider | - [ ] |
| 11 | AI Service | - [ ] |
| 12 | Chat Provider | - [ ] |
| 13 | Mood Provider | - [ ] |
| 14 | Mood Avatar Widget | - [ ] |
| 15 | Message Bubble Widget | - [ ] |
| 16 | Home Screen | - [ ] |
| 17 | Chat Screen | - [ ] |
| 18 | Timeline Screen | - [ ] |
| 19 | Settings Screen | - [ ] |
| 20 | Notification Service | - [ ] |
| 21 | Final Integration & Testing | - [ ] |

**Estimated Total Time:** ~10-13 days (individual tasks: 30 min - 2 hours each)
