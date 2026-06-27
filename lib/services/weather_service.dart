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
