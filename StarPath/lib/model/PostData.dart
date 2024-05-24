import 'package:starpath/model/user_data.dart';

class PostData {
  String id_user = '-1';
  String id_post = '-1';
  String content = 'vacio';
  String description = 'vacio';
  int like = -1;
  int dislike = -1;
  String created_at = 'vacio';
  UserData userData = UserData.empty();

  @override
  String toString() {
    return 'PostData{id_user: $id_user, id_post: $id_post, content: $content, description: $description, like: $like, dislike: $dislike, created_at: $created_at}';
  }
}
