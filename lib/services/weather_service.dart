import 'package:dio/dio.dart';

class WeatherData {
  final double temperature;
  final String condition;
  final String icon;
  final int humidity;
  final double windSpeed;
  final List<HourlyForecast> hourlyForecast;

  const WeatherData({
    required this.temperature,
    required this.condition,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
    this.hourlyForecast = const [],
  });
}

class HourlyForecast {
  final int hour;
  final double temperature;
  final String icon;

  const HourlyForecast({required this.hour, required this.temperature, required this.icon});
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
          'current': 'temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m',
          'hourly': 'temperature_2m,weather_code',
          'forecast_hours': 12,
        },
      );

      if (response.statusCode == 200 && response.data['current'] != null) {
        final current = response.data['current'];
        final weatherCode = current['weather_code'] ?? 0;

        // 解析小时预报
        List<HourlyForecast> hourly = [];
        if (response.data['hourly'] != null) {
          final times = response.data['hourly']['time'] as List? ?? [];
          final temps = response.data['hourly']['temperature_2m'] as List? ?? [];
          final codes = response.data['hourly']['weather_code'] as List? ?? [];
          final now = DateTime.now();
          for (int i = 0; i < times.length && i < 12; i++) {
            final hour = DateTime.parse(times[i]).hour;
            if (hour >= now.hour || i > 0) {
              hourly.add(HourlyForecast(
                hour: hour,
                temperature: (temps[i] ?? 0).toDouble(),
                icon: _getIcon(codes[i] ?? 0),
              ));
            }
          }
        }

        return WeatherData(
          temperature: (current['temperature_2m'] ?? 0).toDouble(),
          condition: _getCondition(weatherCode),
          icon: _getIcon(weatherCode),
          humidity: (current['relative_humidity_2m'] ?? 0).toInt(),
          windSpeed: (current['wind_speed_10m'] ?? 0).toDouble(),
          hourlyForecast: hourly,
        );
      }
      return null;
    } catch (e) {
      print('[Weather] Error: $e');
      return null;
    }
  }

  String _getCondition(int code) {
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

  String _getIcon(int code) {
    if (code <= 1) return '☀️';
    if (code <= 3) return '⛅';
    if (code <= 49) return '🌫️';
    if (code <= 59) return '🌧️';
    if (code <= 69) return '🌧️';
    if (code <= 79) return '❄️';
    if (code <= 82) return '🌦️';
    if (code <= 86) return '🌨️';
    if (code <= 99) return '⛈️';
    return '🌤️';
  }
}
