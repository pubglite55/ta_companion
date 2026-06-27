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
