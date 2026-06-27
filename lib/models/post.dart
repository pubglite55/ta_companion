enum PostType {
  text,
  image,
}

class CommentItem {
  final String text;
  final bool isAI;
  final bool isReply;

  const CommentItem({required this.text, this.isAI = false, this.isReply = false});
}

class Post {
  final String id;
  final String content;
  final PostType type;
  final DateTime timestamp;
  final int likes;
  final int comments;
  final bool isLiked;
  final bool isMine;
  final List<CommentItem> commentList;
  final Map<String, dynamic>? media;

  const Post({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.likes = 0,
    this.comments = 0,
    this.isLiked = false,
    this.isMine = false,
    this.commentList = const [],
    this.media,
  });

  Post copyWith({
    String? content,
    int? likes,
    int? comments,
    bool? isLiked,
    bool? isMine,
    List<CommentItem>? commentList,
    Map<String, dynamic>? media,
  }) {
    return Post(
      id: id,
      content: content ?? this.content,
      type: type,
      timestamp: timestamp,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      isLiked: isLiked ?? this.isLiked,
      isMine: isMine ?? this.isMine,
      commentList: commentList ?? this.commentList,
      media: media ?? this.media,
    );
  }
}
