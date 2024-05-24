class Comment {
  String commentId;
  String postId;
  String comment;
  int likes;
  int dislikes;
  bool deleted;
  String userId;
  Future<List<Map<String, dynamic>>> profilePictureFuture; // Nueva propiedad

  Comment({
    required this.commentId,
    required this.postId,
    required this.comment,
    required this.likes,
    required this.dislikes,
    required this.deleted,
    required this.userId,
    required this.profilePictureFuture, // Nueva propiedad
  });
}
