import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/post.dart';
import '../config/colors.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback? onLike;
  final Function(int)? onComment;

  const PostCard({super.key, required this.post, this.onLike, this.onComment});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头像和名字
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.accent,
                  child: const Text('TA', style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('TA', style: TextStyle(fontWeight: FontWeight.w600)),
                    Text(_formatTime(post.timestamp), style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 内容
            Text(post.content, style: const TextStyle(fontSize: 15, height: 1.5)),
            // 图片
            if (post.type == PostType.image && post.media?['imageUrl'] != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  post.media!['imageUrl'],
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 200,
                    color: AppColors.background,
                    child: const Center(child: Icon(Icons.image_not_supported, color: AppColors.textLight)),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            // 操作栏
            Row(
              children: [
                // 点赞
                _buildAction(
                  icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
                  color: post.isLiked ? Colors.red : AppColors.textSecondary,
                  count: post.likes,
                  onTap: onLike,
                ),
                const SizedBox(width: 20),
                // 评论
                _buildAction(
                  icon: Icons.chat_bubble_outline,
                  color: AppColors.textSecondary,
                  count: post.comments,
                  onTap: () => _showCommentDialog(context),
                ),
                const SizedBox(width: 20),
                // 复制
                _buildAction(
                  icon: Icons.copy_outlined,
                  color: AppColors.textSecondary,
                  onTap: () => _copyContent(context),
                ),
              ],
            ),
            // 评论列表
            if (post.commentList.isNotEmpty) ...[
              const Divider(height: 20),
              ...post.commentList.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: AppColors.accentGreen,
                      child: const Text('我', style: TextStyle(fontSize: 10, color: Colors.white)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(c, style: const TextStyle(fontSize: 13)),
                    ),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAction({required IconData icon, required Color color, int? count, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            if (count != null) ...[
              const SizedBox(width: 4),
              Text('$count', style: TextStyle(color: color, fontSize: 13)),
            ],
          ],
        ),
      ),
    );
  }

  void _showCommentDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('评论'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: '写点什么...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                onComment?.call(0);
                Navigator.pop(ctx);
              }
            },
            child: const Text('发送'),
          ),
        ],
      ),
    ).then((_) {
      if (controller.text.isNotEmpty) {
        // 通过回调传递评论内容
        final comment = controller.text;
        // 这里需要通过回调处理
      }
    });
  }

  void _copyContent(BuildContext context) {
    Clipboard.setData(ClipboardData(text: post.content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已复制到剪贴板'), duration: Duration(seconds: 1)),
    );
  }

  String _formatTime(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    return '${diff.inDays}天前';
  }
}
