import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../config/colors.dart';
import '../services/ai_service.dart';
import '../providers/settings_provider.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  final AiService _aiService = AiService();
  final Dio _dio = Dio();
  String _fact = '加载中...';
  String _quote = '';
  String _quoteAuthor = '';
  String _artUrl = '';
  String _artTitle = '';
  String _artArtist = '';
  bool _isLoading = true;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _loadFact(),
      _loadQuote(),
      _loadArt(),
    ]);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadFact() async {
    final settings = ref.read(settingsProvider);
    if (settings.aiApiKey != null && settings.aiApiKey!.isNotEmpty) {
      try {
        final response = await _aiService.sendMessage(
          provider: settings.aiProvider!,
          apiKey: settings.aiApiKey!,
          systemPrompt: settings.customPrompt ?? '你是一个知识渊博的AI伴侣，说话有趣、有知识含量。用中文回复。',
          messages: [
            {'role': 'user', 'content': '请分享一条有趣的冷知识，简短有趣，不超过50字，带一个emoji'},
          ],
          baseUrl: settings.aiBaseUrl,
          model: settings.aiModel,
        );
        if (mounted) setState(() => _fact = response);
        return;
      } catch (e) {
        print('[Discover] AI fact error: $e');
      }
    }
    // 兜底
    final facts = [
      '章鱼有三颗心脏 🐙',
      '蜂蜜永远不会变质 🍯',
      '草莓不是浆果，香蕉才是 🍓',
      '蜗牛可以睡3年 🐌',
      '金鱼记忆可以持续好几个月 🐟',
    ];
    if (mounted) setState(() => _fact = facts[DateTime.now().millisecond % facts.length]);
  }

  Future<void> _loadQuote() async {
    final settings = ref.read(settingsProvider);
    if (settings.aiApiKey != null && settings.aiApiKey!.isNotEmpty) {
      try {
        final response = await _aiService.sendMessage(
          provider: settings.aiProvider!,
          apiKey: settings.aiApiKey!,
          systemPrompt: settings.customPrompt ?? '你是一个有文学素养的AI伴侣。用中文回复。',
          messages: [
            {'role': 'user', 'content': '请分享一句优美的名言或诗词，要有作者，格式：名言 —— 作者'},
          ],
          baseUrl: settings.aiBaseUrl,
          model: settings.aiModel,
        );
        // 解析名言和作者
        if (response.contains('——')) {
          final parts = response.split('——');
          if (mounted) {
            setState(() {
              _quote = parts[0].trim().replaceAll(RegExp(r'^["「「]|["」」]$'), '');
              _quoteAuthor = parts[1].trim();
            });
          }
        } else {
          if (mounted) setState(() => _quote = response);
        }
        return;
      } catch (e) {
        print('[Discover] AI quote error: $e');
      }
    }
    // 兜底
    if (mounted) {
      setState(() {
        _quote = '生活不止眼前的苟且，还有诗和远方';
        _quoteAuthor = '高晓松';
      });
    }
  }

  Future<void> _loadArt() async {
    try {
      final objectId = 45000 + (DateTime.now().millisecondsSinceEpoch % 5000);
      final r = await _dio.get('https://collectionapi.metmuseum.org/public/collection/v1/objects/$objectId');
      if (r.statusCode == 200 && mounted) {
        setState(() {
          _artTitle = r.data['title'] ?? '';
          _artArtist = r.data['artistDisplayName'] ?? '';
          _artUrl = r.data['primaryImage'] ?? '';
        });
      }
    } catch (e) {
      if (mounted) setState(() => _artTitle = '艺术品加载中...');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('发现'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_isGenerating)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            IconButton(
              icon: const Icon(Icons.auto_awesome),
              onPressed: _refreshAll,
              tooltip: 'AI 重新生成',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshAll,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildFactCard(),
                  const SizedBox(height: 12),
                  _buildQuoteCard(),
                  const SizedBox(height: 12),
                  _buildArtCard(),
                ],
              ),
            ),
    );
  }

  Future<void> _refreshAll() async {
    setState(() => _isGenerating = true);
    await _loadAll();
    setState(() => _isGenerating = false);
  }

  Widget _buildFactCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('💡 冷知识', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                Text('AI 生成', style: TextStyle(fontSize: 11, color: AppColors.textLight)),
              ],
            ),
            const SizedBox(height: 8),
            Text(_fact, style: const TextStyle(fontSize: 15, height: 1.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuoteCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('✨ 每日名言', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                Text('AI 生成', style: TextStyle(fontSize: 11, color: AppColors.textLight)),
              ],
            ),
            const SizedBox(height: 8),
            Text('「$_quote」', style: const TextStyle(fontSize: 15, fontStyle: FontStyle.italic, height: 1.5)),
            if (_quoteAuthor.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('— $_quoteAuthor', style: TextStyle(color: AppColors.textSecondary)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildArtCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🎨 每日艺术品', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (_artUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  _artUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 200,
                    color: AppColors.background,
                    child: const Center(child: Icon(Icons.image, size: 48, color: AppColors.textLight)),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            if (_artTitle.isNotEmpty)
              Text(_artTitle, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            if (_artArtist.isNotEmpty)
              Text(_artArtist, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
