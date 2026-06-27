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
