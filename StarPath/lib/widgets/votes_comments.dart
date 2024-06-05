import 'package:flutter/material.dart';
import 'package:starpath/misc/constants.dart';
import 'package:starpath/model/comment.dart';

class VotesForComments extends StatefulWidget {
  final Comment comment;
  final Function(int, int) onUpdate;

  const VotesForComments(
      {Key? key, required this.comment, required this.onUpdate})
      : super(key: key);

  @override
  _VotesForCommentsState createState() => _VotesForCommentsState();
}

class _VotesForCommentsState extends State<VotesForComments> {
  bool pressedLike = false, pressedDislike = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        GestureDetector(
          onTap: () async {
            setState(() {
              if (!pressedLike) {
                if (pressedDislike) {
                  pressedDislike = false;
                  widget.onUpdate(
                      widget.comment.likes, widget.comment.dislikes - 1);
                }
                pressedLike = true;
                widget.onUpdate(
                    widget.comment.likes + 1, widget.comment.dislikes);
              } else {
                pressedLike = false;
                widget.onUpdate(
                    widget.comment.likes - 1, widget.comment.dislikes);
              }
            });
            await updateLikesAsync();
          },
          child: const Icon(Icons.thumb_up),
        ),
        Text("${widget.comment.likes}"),
        GestureDetector(
          onTap: () async {
            setState(() {
              if (!pressedDislike) {
                if (pressedLike) {
                  pressedLike = false;
                  widget.onUpdate(
                      widget.comment.likes - 1, widget.comment.dislikes);
                }
                pressedDislike = true;
                widget.onUpdate(
                    widget.comment.likes, widget.comment.dislikes + 1);
              } else {
                pressedDislike = false;
                widget.onUpdate(
                    widget.comment.likes, widget.comment.dislikes - 1);
              }
            });
            await updateLikesAsync();
          },
          child: const Icon(Icons.thumb_down),
        ),
        Text("${widget.comment.dislikes}"),
      ],
    );
  }

  Future<void> updateLikesAsync() async {
    await supabase.from("comment").update({
      'likes': widget.comment.likes,
      'dislikes': widget.comment.dislikes,
    }).eq('id_comment', widget.comment.commentId);
  }
}
