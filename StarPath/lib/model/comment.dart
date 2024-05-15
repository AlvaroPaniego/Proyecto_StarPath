class Comment {
  final String userId;
  final String postId;
  final String comment;
  final int likes;
  final int dislikes;
  final bool deleted;

  Comment({
    required this.userId,
    required this.postId,
    required this.comment,
    required this.likes,
    required this.dislikes,
    required this.deleted,
  });
}
