import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:starpath/misc/constants.dart';
import 'package:starpath/widgets/avatar_button.dart';
import 'package:starpath/widgets/votes_comments.dart';
import 'package:http/http.dart' as http;

import '../model/comment.dart';

class CommentCard extends StatefulWidget {
  final Comment comment;
  const CommentCard({super.key, required this.comment});

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  bool isAlreadyTranslated = false;
  late String translatedComment;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          AvatarButton(
            profilePictureFuture:
            widget.comment.profilePictureFuture,
            user: widget.comment.userData,
          ),
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<String>(
                  future:
                  getCommentUsernameAsync(widget.comment.userId),
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
                    : widget.comment.comment
                ),
                TextButton(
                    onPressed:  () async => await translateComment(widget.comment.comment, isAlreadyTranslated),
                    child: const Text('Traducir')
                )
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: VotesForComments(
              comment: widget.comment,
              onUpdate: (int likes, int dislikes) {
                setState(() {
                  widget.comment.likes = likes;
                  widget.comment.dislikes = dislikes;
                });
              },
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
}
