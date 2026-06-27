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
