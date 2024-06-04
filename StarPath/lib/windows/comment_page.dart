import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:starpath/model/comment.dart';
import 'package:starpath/model/translate_data.dart';
import 'package:starpath/model/user_data.dart';
import 'package:starpath/widgets/avatar_button.dart';
import 'package:starpath/widgets/votes_comments.dart';
import 'package:starpath/misc/constants.dart';
import 'package:starpath/model/user.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class CommentPage extends StatefulWidget {
  final String postId;


  const CommentPage({Key? key, required this.postId}) : super(key: key);

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  late Future<List<Comment>> futureComments;
  late TextEditingController _commentController;
  bool isAlreadyTranslated = false;
  late String translatedComment;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
    futureComments = _loadComments();
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
          .select('*, user(profile_picture)')
          .eq('id_post', widget.postId)
          .match({'deleted': false}).order('created_at', ascending: true);

      final List<Comment> loadedComments = [];

      for (final row in response! as List<Map<String, dynamic>>) {
        if (row['id_comment'] != null &&
            row['id_post'] != null &&
            row['comment'] != null &&
            row['likes'] != null &&
            row['dislikes'] != null &&
            row['deleted'] != null &&
            row['id_user'] != null &&
            row['user'] != null &&
            row['user']['profile_picture'] != null) {
          final comment = Comment(
            commentId: row['id_comment'] as String,
            postId: row['id_post'] as String,
            comment: row['comment'] as String,
            likes: row['likes'] as int,
            dislikes: row['dislikes'] as int,
            deleted: row['deleted'] as bool,
            userId: row['id_user'] as String,
            profilePictureFuture: _getProfilePicture(row['id_user'] as String),
          );

          comment.userData = await getUserDataAsync(comment.userId);
          loadedComments.add(comment);
        } else {
          print('Hay valores nulos');
        }
      }

      print('La longitud de la lista es ${loadedComments.length}');
      return loadedComments;
    } catch (error) {
      print('Error al cargar los comentarios: $error');
      throw error;
    }
  }

  Future<List<Map<String, dynamic>>> _getProfilePicture(String userId) async {
    try {
      final response = await supabase
          .from('user')
          .select('profile_picture')
          .eq('id_user', userId);

      if (response == null) {
        print('Error al obtener la foto de perfil');
        return [];
      }

      final List<Map<String, dynamic>> profilePictureData =
          response as List<Map<String, dynamic>>;
      return profilePictureData;
    } catch (error) {
      print('Error al obtener la foto de perfil: $error');
      return [];
    }
  }

  Future<void> _addComment() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.user;
    final userId = userProvider.user?.id;
    if (currentUser != null) {
      final newComment = Comment(
          commentId: const Uuid().v4(),
          postId: widget.postId,
          comment: _commentController.text.trim(),
          likes: 0,
          dislikes: 0,
          deleted: false,
          userId: currentUser.id,
          profilePictureFuture: _getProfilePicture(userId ?? ""));

      try {
        await supabase.from('comment').insert([
          {
            'id_comment': newComment.commentId,
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
        print('Error al añadir comentario: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comentarios del Post ${widget.postId}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Comment>>(
              future: futureComments,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final comments = snapshot.data!;

                  return ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index)  {
                      final comment = comments[index];
                      return Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            AvatarButton(
                              profilePictureFuture:
                                  comment.profilePictureFuture,
                                  user: comment.userData,
                            ),
                            Expanded(
                              flex: 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FutureBuilder<String>(
                                    future:
                                        getCommentUsernameAsync(comment.userId),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        return Text(
                                          snapshot.data!,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        );
                                      } else {
                                        return Text(
                                          'Cargando Usuario', //texto temporal mientras se carga el nombre de usuario
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        );
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 4),
                                  Text(isAlreadyTranslated
                                      ? translatedComment
                                      : comment.comment
                                  ),
                                  TextButton(
                                      onPressed:  () async => await translateComment(comment.comment, isAlreadyTranslated),
                                      child: const Text('Traducir')
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: VotesForComments(
                                comment: comment,
                                onUpdate: (int likes, int dislikes) {
                                  setState(() {
                                    comment.likes = likes;
                                    comment.dislikes = dislikes;
                                  });
                                },
                              ),
                            ),
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
  Future<void>translateComment(String comment, bool isEnglish) async{
    var data = jsonEncode({
      'q': comment,
      'source': isEnglish ? 'EN' : 'ES',
      'target': isEnglish ? 'ES' : 'EN',
    });
    print(data);
    final res = await http.post(
        Uri.parse('https://deep-translate1.p.rapidapi.com/language/translate/v2'),
      headers: {
        'x-rapidapi-key': TRANSLATOR_API_KEY,
        'Content-Type': 'application/json',
        'X-RapidAPI-Host': 'deep-translate1.p.rapidapi.com',
      },
      body: data
    );
    if(res.statusCode == 200){
      final responseData = utf8.decode(res.bodyBytes);
      final jsonData = jsonDecode(responseData);
      var resComment = jsonData['data']['translations']['translatedText'];
      setState(() {
        print('seteando');
        isAlreadyTranslated = !isEnglish;
        translatedComment = resComment;
        print(translatedComment);
      });
    }
  }
  Future<String> getCommentUsernameAsync(String userId) async {
    String userName =
        "Cargando Usuario"; // texto temporal mientras se carga el nombre de usuario
    var res = await supabase
        .from('user')
        .select("username")
        .match({'id_user': userId});
    userName = res[0]['username'];
    return userName;
  }
  Future<UserData> getUserDataAsync(String id_user) async{
    UserData user = UserData.empty();
    var res = await supabase
        .from('user')
        .select("id_user, username, profile_picture")
        .match({'id_user': id_user});
    user.id_user = res.first['id_user'];
    user.username = res.first['username'];
    user.profile_picture = res.first['profile_picture'];
    user.followers = '0';
    print(user.username);
    return user;
  }
}
