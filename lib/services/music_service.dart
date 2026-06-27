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
