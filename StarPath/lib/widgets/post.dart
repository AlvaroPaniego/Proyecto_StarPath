import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:starpath/model/PostData.dart';
import 'package:starpath/widgets/up-down_votes.dart';
import 'package:starpath/windows/comment_page.dart';
import 'package:starpath/windows/main_page.dart';
import 'package:starpath/misc/constants.dart';
import 'package:provider/provider.dart';
import 'package:starpath/model/user.dart';
import 'package:supabase/supabase.dart';

class Post extends StatefulWidget {
  final PostData postData;

  const Post({Key? key, required this.postData}) : super(key: key);

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  int numComments = 0;

  @override
  Widget build(BuildContext context) {
    if (!mounted) {
      return Container(); // Widget desactivado, retornamos un contenedor vacío
    }

    final currentUser = context.watch<UserProvider>().user;
    Future<bool> isCurrentUserPostAuthor(String currentUserId) async {
      if (currentUserId != null) {
        String username = await getUsername(currentUserId);
        return widget.postData.id_user == username;
      }
      return false;
    }

    var idee = currentUser?.id;
    var ide = widget.postData.id_user;
    print('Is current user the author: $isCurrentUserPostAuthor');
    print('widget.postData.id_user: $ide');
    print('currentUser.id: $idee');
    print(getUsername(currentUser!.id));

    Future<String> futureCommentCount = Future.value("");
    String user = widget.postData.id_user,
        description = widget.postData.description;

    bool hasValidImage = widget.postData.content.isNotEmpty;
    futureCommentCount = getCommentCount(widget.postData.id_post);
    Future<String> futureUsername = getUsername(currentUser!.id);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: POST_BACKGROUND,
              borderRadius: BorderRadius.circular(25.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  flex: 2,
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(25.0)),
                    child: hasValidImage
                        ? Image.network(widget.postData.content)
                        : Image.asset("assets/images/placeholder-image.jpg"),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FutureBuilder<bool>(
                        future: isCurrentUserPostAuthor(currentUser!.id),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data == true) {
                            return GestureDetector(
                              onTap: () {
                                _showDeleteConfirmationDialog(context);
                              },
                              child: const Icon(Icons.delete),
                            );
                          } else {
                            return Container();
                          }
                        },
                      ),
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FutureBuilder<String>(
                                future: futureUsername,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Text(snapshot.data ?? '');
                                  } else {
                                    return Text(
                                        'Cargando nombre de usuario...');
                                  }
                                },
                              ),
                              Text(description),
                            ],
                          ),
                        ),
                      ),
                      Votes(
                        likes: widget.postData.like,
                        dislikes: widget.postData.dislike,
                        id_post: widget.postData.id_post,
                      ),
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () {
                            String postId = widget.postData.id_post;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CommentPage(
                                  post: widget.postData,
                                  hasReturnToMain: true,
                                ),
                              ),
                            );
                          },
                          child: FutureBuilder(
                            future: futureCommentCount,
                            builder: (context, snapshot) {
                              if (snapshot.hasData &&
                                  snapshot.data!.isNotEmpty) {
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    const Icon(Icons.comment),
                                    Text(snapshot.data!)
                                  ],
                                );
                              }
                              return const Icon(Icons.comment);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<String> getCommentCount(String idPost) async {
    String commentCount = '0';
    var res = await supabase.from('comment').count().eq('id_post', idPost);
    commentCount = res.toString();
    return commentCount;
  }

  Future<void> _deletePost(String postId) async {
    try {
      await supabase.from('post').delete().eq('id_post', postId);

      // Navegar de regreso a la MainPage después de eliminar el post
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainPage()),
      );
    } catch (error) {
      print('Error al eliminar el post: $error');
    }
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Eliminar publicación'),
          content:
              Text('¿Estás seguro de que deseas eliminar esta publicación?'),
          actions: <Widget>[
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            CupertinoDialogAction(
              onPressed: () {
                _deletePost(widget.postData.id_post);
                Navigator.of(context).pop();
              },
              isDestructiveAction: true,
              child: Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  Future<String> getUsername(String userId) async {
    final response =
        await supabase.from('user').select('username').eq('id_user', userId);

    if (response != null && response.isNotEmpty) {
      final username = response[0]['username'];

      return username.toString();
    } else {
      return '';
    }
  }
}
