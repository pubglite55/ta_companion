import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/post.dart';
import '../config/colors.dart';
import '../services/ai_service.dart';
import '../providers/settings_provider.dart';
import '../providers/intimacy_provider.dart';

class TimelineScreen extends ConsumerStatefulWidget {
  const TimelineScreen({super.key});

  @override
  ConsumerState<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends ConsumerState<TimelineScreen> {
  final AiService _aiService = AiService();
  final Box _box = Hive.box('cache');
  final List<Post> _posts = [];
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  // 从本地加载帖子
  void _loadPosts() {
    try {
      final saved = _box.get('timeline_posts', defaultValue: []) as List;
      if (saved.isNotEmpty) {
        _posts.addAll(saved.map((item) {
          if (item is Map) {
            final commentData = item['commentList'] as List? ?? [];
            return Post(
              id: item['id'] ?? '',
              content: item['content'] ?? '',
              type: PostType.values[item['type'] ?? 0],
              timestamp: DateTime.tryParse(item['timestamp'] ?? '') ?? DateTime.now(),
              likes: item['likes'] ?? 0,
              comments: item['comments'] ?? 0,
              isLiked: item['isLiked'] ?? false,
              isMine: item['isMine'] ?? false,
              media: item['media'] != null ? Map<String, dynamic>.from(item['media']) : null,
              commentList: commentData.map((c) => CommentItem(
                text: c['text'] ?? '',
                isAI: c['isAI'] ?? false,
                isReply: c['isReply'] ?? false,
              )).toList(),
            );
          }
          return null;
        }).where((p) => p != null).cast<Post>().toList());
      } else {
        _posts.addAll([
          Post(id: '1', content: '今天天气真好，心情也跟着好起来了 ☀️', type: PostType.text, timestamp: DateTime.now().subtract(const Duration(minutes: 30)), likes: 5, isMine: false),
          Post(id: '2', content: '看到这幅画好美，想和你一起欣赏 🎨', type: PostType.image, timestamp: DateTime.now().subtract(const Duration(hours: 2)), likes: 8, isMine: false, media: {'imageUrl': 'https://picsum.photos/seed/art1/800/600'}),
        ]);
        _savePosts();
      }
    } catch (e) {
      print('[Timeline] Load error: $e');
    }
  }

  // 保存帖子到本地
  void _savePosts() {
    try {
      final data = _posts.map((p) => {
        'id': p.id,
        'content': p.content,
        'type': p.type.index,
        'timestamp': p.timestamp.toIso8601String(),
        'likes': p.likes,
        'comments': p.comments,
        'isLiked': p.isLiked,
        'isMine': p.isMine,
        'media': p.media,
        'commentList': p.commentList.map((c) => {
          'text': c.text,
          'isAI': c.isAI,
          'isReply': c.isReply,
        }).toList(),
      }).toList();
      _box.put('timeline_posts', data);
    } catch (e) {
      print('[Timeline] Save error: $e');
    }
  }

  Future<void> _generateAiPost() async {
    final settings = ref.read(settingsProvider);
    if (settings.aiApiKey == null || settings.aiApiKey!.isEmpty) {
      _showSnackBar('请先在设置中配置 AI 服务');
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final response = await _aiService.sendMessage(
        provider: settings.aiProvider!,
        apiKey: settings.aiApiKey!,
        systemPrompt: settings.customPrompt ?? '你是一个活泼可爱的AI伴侣，正在发朋友圈。请用简短的中文发一条朋友圈动态，带上emoji，内容要有趣、温暖、贴近生活。只输出动态内容，不要加引号或其他格式。长度不超过50字。',
        messages: [{'role': 'user', 'content': '请发一条朋友圈动态'}],
        baseUrl: settings.aiBaseUrl,
        model: settings.aiModel,
      );

      final hasImage = DateTime.now().millisecond % 3 == 0;

      setState(() {
        _posts.insert(0, Post(
          id: '${DateTime.now().millisecondsSinceEpoch}',
          content: response,
          type: hasImage ? PostType.image : PostType.text,
          timestamp: DateTime.now(),
          likes: 0,
          isMine: false,
          media: hasImage ? {'imageUrl': 'https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/800/600'} : null,
        ));
        _isGenerating = false;
      });
      _savePosts();
      _showSnackBar('TA 发布了一条新动态');
    } catch (e) {
      setState(() => _isGenerating = false);
      _showSnackBar('生成失败：$e');
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('朋友圈'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_isGenerating)
            const Padding(padding: EdgeInsets.all(16), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
          else
            IconButton(icon: const Icon(Icons.auto_awesome), onPressed: _generateAiPost, tooltip: 'TA 发动态'),
          IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: _showAddPostDialog, tooltip: '我发动态'),
        ],
      ),
      body: _posts.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.dynamic_feed_outlined, size: 64, color: AppColors.textLight),
              const SizedBox(height: 16),
              Text('还没有动态', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
              const SizedBox(height: 12),
              ElevatedButton.icon(onPressed: _generateAiPost, icon: const Icon(Icons.auto_awesome), label: const Text('让 TA 发一条')),
            ]))
          : RefreshIndicator(
              onRefresh: () async => await _generateAiPost(),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _posts.length,
                itemBuilder: (context, index) {
                  return _PostCardWidget(
                    post: _posts[index],
                    onLike: () => _toggleLike(index),
                    onComment: (text) => _addComment(index, text),
                    onReply: (ci, text) => _addReply(index, ci, text),
                  );
                },
              ),
            ),
    );
  }

  void _toggleLike(int index) {
    setState(() {
      final p = _posts[index];
      final wasLiked = p.isLiked;
      _posts[index] = p.copyWith(isLiked: !wasLiked, likes: wasLiked ? p.likes - 1 : p.likes + 1);
    });
    if (!_posts[index].isLiked) {
      ref.read(intimacyProvider.notifier).onLike();
    }
    _savePosts();
  }

  void _addComment(int pi, String text) {
    setState(() {
      final p = _posts[pi];
      _posts[pi] = p.copyWith(commentList: [...p.commentList, CommentItem(text: text, isAI: false)], comments: p.comments + 1);
    });
    ref.read(intimacyProvider.notifier).onComment();
    _savePosts();
    _aiReply(pi);
  }

  void _addReply(int pi, int ci, String text) {
    setState(() {
      final p = _posts[pi];
      final newComments = List<CommentItem>.from(p.commentList);
      newComments.insert(ci + 1, CommentItem(text: text, isAI: false, isReply: true));
      _posts[pi] = p.copyWith(commentList: newComments, comments: p.comments + 1);
    });
    ref.read(intimacyProvider.notifier).onReply();
    _savePosts();
    _aiReply(pi);
  }

  Future<void> _aiReply(int pi) async {
    final settings = ref.read(settingsProvider);
    if (settings.aiApiKey == null || settings.aiApiKey!.isEmpty) return;
    try {
      final p = _posts[pi];
      final recent = p.commentList.length > 3 ? p.commentList.sublist(p.commentList.length - 3).map((c) => c.text).join('\n') : p.commentList.map((c) => c.text).join('\n');
      final response = await _aiService.sendMessage(
        provider: settings.aiProvider!, apiKey: settings.aiApiKey!,
        systemPrompt: settings.customPrompt ?? '你是TA，活泼可爱的AI伴侣。用户评论了你的动态，请简短回复，亲切有趣，带emoji。不超过30字。',
        messages: [{'role': 'user', 'content': '动态：${p.content}\n评论：$recent\n回复最新评论'}],
        baseUrl: settings.aiBaseUrl, model: settings.aiModel,
      );
      setState(() {
        _posts[pi] = _posts[pi].copyWith(
          commentList: [..._posts[pi].commentList, CommentItem(text: response, isAI: true)],
          comments: _posts[pi].comments + 1,
        );
      });
      _savePosts();
    } catch (e) {}
  }

  void _showAddPostDialog() {
    final controller = TextEditingController();
    PostType selectedType = PostType.text;
    showDialog(context: context, builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) => AlertDialog(
        title: const Text('发动态'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: controller, maxLines: 4, decoration: InputDecoration(hintText: '分享此刻的心情...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
          const SizedBox(height: 12),
          Row(children: [
            const Text('类型：', style: TextStyle(fontSize: 14)), const SizedBox(width: 8),
            ChoiceChip(label: const Text('文字'), selected: selectedType == PostType.text, onSelected: (_) => setDialogState(() => selectedType = PostType.text)),
            const SizedBox(width: 8),
            ChoiceChip(label: const Text('图片'), selected: selectedType == PostType.image, onSelected: (_) => setDialogState(() => selectedType = PostType.image)),
          ]),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(onPressed: () async {
            if (controller.text.isNotEmpty) {
              setState(() {
                _posts.insert(0, Post(
                  id: '${DateTime.now().millisecondsSinceEpoch}', content: controller.text, type: selectedType,
                  timestamp: DateTime.now(), likes: 0, isMine: true,
                  media: selectedType == PostType.image ? {'imageUrl': 'https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/800/600'} : null,
                ));
              });
              Navigator.pop(ctx);
              ref.read(intimacyProvider.notifier).onComment();
              _savePosts();
              _showSnackBar('发布成功！');
              _aiReplyToMyPost(0);
            }
          }, child: const Text('发布')),
        ],
      ),
    ));
  }

  Future<void> _aiReplyToMyPost(int pi) async {
    final settings = ref.read(settingsProvider);
    if (settings.aiApiKey == null || settings.aiApiKey!.isEmpty) return;
    try {
      final p = _posts[pi];
      final response = await _aiService.sendMessage(
        provider: settings.aiProvider!, apiKey: settings.aiApiKey!,
        systemPrompt: settings.customPrompt ?? '你是TA，活泼可爱的AI伴侣。用户发了朋友圈动态，请简短评论，亲切有趣，带emoji。不超过30字。',
        messages: [{'role': 'user', 'content': '动态：${p.content}\n请评论'}],
        baseUrl: settings.aiBaseUrl, model: settings.aiModel,
      );
      setState(() {
        _posts[pi] = _posts[pi].copyWith(
          commentList: [..._posts[pi].commentList, CommentItem(text: response, isAI: true)],
          comments: _posts[pi].comments + 1,
        );
      });
      _savePosts();
    } catch (e) {}
  }
}

class _PostCardWidget extends StatelessWidget {
  final Post post;
  final VoidCallback onLike;
  final Function(String) onComment;
  final Function(int, String) onReply;

  const _PostCardWidget({required this.post, required this.onLike, required this.onComment, required this.onReply});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(
              backgroundColor: post.isMine ? AppColors.accentGreen : AppColors.accent,
              child: Text(post.isMine ? '我' : 'TA', style: const TextStyle(color: Colors.white, fontSize: 12)),
            ),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(post.isMine ? '我' : 'TA', style: TextStyle(fontWeight: FontWeight.w600, color: post.isMine ? AppColors.accentGreen : AppColors.textPrimary)),
              Text(_formatTime(post.timestamp), style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ]),
          ]),
          const SizedBox(height: 12),
          Text(post.content, style: const TextStyle(fontSize: 15, height: 1.5)),
          if (post.type == PostType.image && post.media?['imageUrl'] != null) ...[
            const SizedBox(height: 12),
            ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(post.media!['imageUrl'], width: double.infinity, height: 200, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(height: 200, color: AppColors.background, child: const Center(child: Icon(Icons.image, size: 48, color: AppColors.textLight))))),
          ],
          const SizedBox(height: 12),
          Row(children: [
            _buildAction(icon: post.isLiked ? Icons.favorite : Icons.favorite_border, color: post.isLiked ? Colors.red : AppColors.textSecondary, count: post.likes, onTap: onLike),
            const SizedBox(width: 20),
            _buildAction(icon: Icons.chat_bubble_outline, color: AppColors.textSecondary, count: post.comments, onTap: () => _showCommentInput(context)),
          ]),
          if (post.commentList.isNotEmpty) ...[
            const Divider(height: 20),
            Container(
              padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                for (int i = 0; i < post.commentList.length; i++) _buildCommentItem(context, i, post.commentList[i]),
              ]),
            ),
          ],
        ]),
      ),
    );
  }

  Widget _buildAction({required IconData icon, required Color color, int? count, VoidCallback? onTap}) {
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(20),
      child: Padding(padding: const EdgeInsets.all(4), child: Row(children: [
        Icon(icon, size: 20, color: color),
        if (count != null && count > 0) ...[const SizedBox(width: 4), Text('$count', style: TextStyle(color: color, fontSize: 13))],
      ])));
  }

  Widget _buildCommentItem(BuildContext context, int index, CommentItem comment) {
    return Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      CircleAvatar(radius: 10, backgroundColor: comment.isAI ? AppColors.accent : AppColors.accentGreen,
        child: Text(comment.isAI ? 'TA' : '我', style: const TextStyle(fontSize: 8, color: Colors.white))),
      const SizedBox(width: 8),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(comment.isAI ? 'TA' : '我', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: comment.isAI ? AppColors.accent : AppColors.accentGreen)),
        Text(comment.text, style: const TextStyle(fontSize: 13)),
      ])),
      InkWell(onTap: () => _showReplyInput(context, index), child: Text('回复', style: TextStyle(fontSize: 11, color: AppColors.textSecondary))),
    ]));
  }

  void _showCommentInput(BuildContext context) {
    final controller = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('评论'),
      content: TextField(controller: controller, autofocus: true, maxLines: 3, decoration: InputDecoration(hintText: '说点什么...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
        TextButton(onPressed: () { if (controller.text.isNotEmpty) { onComment(controller.text); Navigator.pop(ctx); } }, child: const Text('发送')),
      ],
    ));
  }

  void _showReplyInput(BuildContext context, int commentIndex) {
    final controller = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('回复'),
      content: TextField(controller: controller, autofocus: true, maxLines: 2, decoration: InputDecoration(hintText: '回复...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
        TextButton(onPressed: () { if (controller.text.isNotEmpty) { onReply(commentIndex, controller.text); Navigator.pop(ctx); } }, child: const Text('发送')),
      ],
    ));
  }

  String _formatTime(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    return '${diff.inDays}天前';
  }
}
