import 'package:flutter/material.dart';
import '../models/post.dart';
import '../widgets/post_card.dart';

class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final posts = [
      Post(
        id: '1',
        content: '今天在咖啡馆听了一首很棒的歌~',
        type: PostType.song,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        likes: 12,
        comments: 3,
        media: {'songName': 'Jazz Café', 'artist': 'Various'},
      ),
      Post(
        id: '2',
        content: '看到这幅画好美，分享给你~',
        type: PostType.image,
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        likes: 8,
        comments: 1,
        media: {'imageUrl': 'https://images.metmuseum.org/CRDImages/ep/original/DT1567.jpg'},
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('朋友圈'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return PostCard(post: posts[index]);
        },
      ),
    );
  }
}
