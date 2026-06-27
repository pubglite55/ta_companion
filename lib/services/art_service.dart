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
