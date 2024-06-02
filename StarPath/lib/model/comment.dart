import 'package:starpath/model/user_data.dart';

class Comment {
  String commentId;
  String postId;
  String comment;
  int likes;
  int dislikes;
  bool deleted;
  String userId;
  Future<List<Map<String, dynamic>>> profilePictureFuture;
  UserData userData = UserData.empty();

  Comment({
    required this.commentId,
    required this.postId,
    required this.comment,
    required this.likes,
    required this.dislikes,
    required this.deleted,
    required this.userId,
    required this.profilePictureFuture,
  });
}
