import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:starpath/model/comment.dart';
import 'package:starpath/model/user.dart';
import 'package:provider/provider.dart';
import 'package:supabase/supabase.dart';
import 'package:uuid/uuid.dart';
import 'package:starpath/misc/constants.dart';
import 'package:starpath/widgets/avatar_button.dart';

class CommentPage extends StatefulWidget {
  final String postId;

  const CommentPage({Key? key, required this.postId}) : super(key: key);

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  late Future<List<Comment>> futureComments;

  late TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
    futureComments = _loadComments();
    supabase.channel('post_upvotes_changes').onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'post',
        callback: (payload) {
          setState(() {
            //actuaizar los likes/dislikes

          });
        },).subscribe();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<List<Comment>> _loadComments() async {
    try {
      final response = await supabase
          .from('comment')
          .select("*")
          .match({'id_post': widget.postId});

      final List<Comment> loadedComments = [];

      for (final row in response) {
        if (row['id_post'] != null &&
            row['comment'] != null &&
            row['likes'] != null &&
            row['dislikes'] != null &&
            row['deleted'] != null &&
            row['id_user'] != null) {
          loadedComments.add(
            Comment(
              postId: row['id_post'] as String,
              comment: row['comment'] as String,
              likes: row['likes'] as int,
              dislikes: row['dislikes'] as int,
              deleted: row['deleted'] as bool,
              userId: row['id_user'] as String,
            ),
          );
        } else {
          print('hay valores nulos');
        }
      }

      print('la longitud de la lista es ${loadedComments.length}');
      return loadedComments;
    } catch (error) {
      print('Error añadir commentario: $error');
      throw error;
    }
  }

  Future<void> _addComment() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.user;
    if (currentUser != null) {
      final newComment = Comment(
        postId: widget.postId,
        comment: _commentController.text.trim(),
        likes: 0,
        dislikes: 0,
        deleted: false,
        userId: currentUser.id,
      );

      try {
        final idComment = const Uuid().v4();

        await supabase.from('comment').insert([
          {
            'id_comment': idComment,
            'id_user': currentUser.id,
            'id_post': newComment.postId,
            'comment': newComment.comment,
            'likes': newComment.likes,
            'dislikes': newComment.dislikes,
            'deleted': newComment.deleted,
          }
        ]);

        setState(() {
          print('Comentario insertado correctamente');
          futureComments = _loadComments();
        });

        _commentController.clear();
      } catch (error) {
        print('Error añadir commentario: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Commentarios del Post ${widget.postId}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Comment>>(
              future: futureComments,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final comments = snapshot.data!;
                  return ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      return Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const AvatarButton(),
                            Expanded(
                              flex: 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FutureBuilder<String>(
                                    future: getCommentUsernameAsync(comment.userId),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        return Text(
                                          '${snapshot.data}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        );
                                      } else {
                                        return const Text(
                                          'Usuario',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        );
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    comment.comment,
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      // Implementar código para like
                                    },
                                    icon: const Icon(Icons.thumb_up),
                                  ),
                                  Text('${comment.likes}'),
                                  IconButton(
                                    onPressed: () {
                                      // Implementar código para dislike
                                    },
                                    icon: const Icon(Icons.thumb_down),
                                  ),
                                  Text('${comment.dislikes}'),
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Escribe un comentario...',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _addComment,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<String> getCommentUsernameAsync(String userId) async {
    String userName = "error";
    var res = await supabase
        .from('user')
        .select("username")
        .match({'id_user': userId});
    userName = res[0]['username'];
    return userName;
  }
}
