import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../config/colors.dart';
import '../providers/mood_provider.dart';
import '../providers/settings_provider.dart';
import '../services/weather_service.dart';
import '../widgets/mood_avatar.dart';
import 'chat_screen.dart';
import 'timeline_screen.dart';
import 'settings_screen.dart';
import 'discover_screen.dart';
import 'mood_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final WeatherService _weatherService = WeatherService();
  WeatherData? _weather;
  String _greeting = '';
  String _locationName = '定位中...';
  bool _isLoadingWeather = true;

  @override
  void initState() {
    super.initState();
    _updateGreeting();
    _loadWeatherWithLocation();
  }

  void _updateGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) {
      _greeting = '夜深了，还没睡呀';
    } else if (hour < 12) {
      _greeting = '早上好，新的一天开始了';
    } else if (hour < 14) {
      _greeting = '中午好，吃饭了吗';
    } else if (hour < 18) {
      _greeting = '下午好，今天过得怎么样';
    } else if (hour < 22) {
      _greeting = '晚上好，辛苦一天了';
    } else {
      _greeting = '夜深了，早点休息哦';
    }
  }

  Future<void> _loadWeatherWithLocation() async {
    try {
      print('[Weather] Starting...');
      
      // 检查定位服务是否开启
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      print('[Weather] Location service enabled: $serviceEnabled');
      
      if (!serviceEnabled) {
        print('[Weather] Location service disabled, using default');
        setState(() {
          _locationName = '北京（默认）';
          _isLoadingWeather = false;
        });
        await _loadWeather(39.9042, 116.4074);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      print('[Weather] Permission: $permission');
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        print('[Weather] Permission denied, using default');
        setState(() {
          _locationName = '北京（默认）';
          _isLoadingWeather = false;
        });
        await _loadWeather(39.9042, 116.4074);
        return;
      }

      print('[Weather] Getting position...');
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 15),
      );
      print('[Weather] Got position: ${position.latitude}, ${position.longitude}');

      setState(() {
        _locationName = '当前位置';
        _isLoadingWeather = false;
      });

      await _loadWeather(position.latitude, position.longitude);
    } catch (e) {
      print('[Weather] Fallback to default: $e');
      setState(() {
        _locationName = '北京（默认）';
        _isLoadingWeather = false;
      });
      await _loadWeather(39.9042, 116.4074);
    }
  }

  Future<void> _loadWeather(double lat, double lon) async {
    final weather = await _weatherService.getCurrentWeather(lat, lon);
    if (mounted) {
      setState(() => _weather = weather);
      ref.read(moodProvider.notifier).updateMood();
    }
  }

  @override
  Widget build(BuildContext context) {
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
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_greeting, style: TextStyle(fontSize: 20, color: AppColors.textSecondary)),
            const SizedBox(height: 20),
            Center(child: MoodAvatar(mood: mood, size: 120)),
            const SizedBox(height: 16),
            Center(
              child: Text(
                '今天心情 ${mood.label} ${mood.emoji}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 24),
            _buildWeatherCard(),
            const SizedBox(height: 16),
            _buildQuickInfoRow(),
            const SizedBox(height: 24),
            _buildActionGrid(context, ref, settings),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _isLoadingWeather
            ? Row(
                children: [
                  const CircularProgressIndicator(strokeWidth: 2),
                  const SizedBox(width: 16),
                  Text('正在获取天气...', style: TextStyle(color: AppColors.textSecondary)),
                ],
              )
            : Column(
                children: [
                  Row(
                    children: [
                      Text(_weather?.icon ?? '🌤️', style: const TextStyle(fontSize: 48)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${_weather?.temperature.round() ?? '--'}°C', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                            Text(_weather?.condition ?? '未知', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                            Text(_locationName, style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.water_drop_outlined, size: 16, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text('${_weather?.humidity ?? '--'}%', style: TextStyle(color: AppColors.textSecondary)),
                          ]),
                          const SizedBox(height: 4),
                          Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.air, size: 16, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text('${_weather?.windSpeed.round() ?? '--'}km/h', style: TextStyle(color: AppColors.textSecondary)),
                          ]),
                        ],
                      ),
                    ],
                  ),
                  // 小时预报
                  if (_weather?.hourlyForecast.isNotEmpty == true) ...[
                    const Divider(height: 24),
                    SizedBox(
                      height: 60,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _weather!.hourlyForecast.length,
                        itemBuilder: (context, index) {
                          final h = _weather!.hourlyForecast[index];
                          return Container(
                            width: 56,
                            margin: const EdgeInsets.only(right: 8),
                            child: Column(
                              children: [
                                Text('${h.hour}:00', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                const SizedBox(height: 4),
                                Text(h.icon, style: const TextStyle(fontSize: 18)),
                                const SizedBox(height: 4),
                                Text('${h.temperature.round()}°', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _buildQuickInfoRow() {
    final date = DateTime.now();
    final weekdays = ['一', '二', '三', '四', '五', '六', '日'];

    return Row(
      children: [
        _buildQuickItem(Icons.calendar_today, '${date.month}月${date.day}日 周${weekdays[date.weekday - 1]}'),
        const SizedBox(width: 12),
        _buildQuickItem(Icons.access_time, '${date.hour}:${date.minute.toString().padLeft(2, '0')}'),
      ],
    );
  }

  Widget _buildQuickItem(IconData icon, String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: AppColors.accent),
            const SizedBox(width: 6),
            Text(text, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context, WidgetRef ref, AppSettings settings) {
    final items = [
      _ActionItem(Icons.chat_bubble_outline, '聊天', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()))),
      _ActionItem(Icons.dynamic_feed_outlined, '朋友圈', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TimelineScreen()))),
      _ActionItem(Icons.explore_outlined, '发现', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DiscoverScreen()))),
      _ActionItem(Icons.mood_outlined, '心情', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MoodScreen()))),
      _ActionItem(Icons.settings_outlined, '设置', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          child: InkWell(
            onTap: item.onTap,
            borderRadius: BorderRadius.circular(12),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item.icon, color: AppColors.accent),
                  const SizedBox(width: 8),
                  Text(item.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ActionItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  _ActionItem(this.icon, this.label, this.onTap);
}
