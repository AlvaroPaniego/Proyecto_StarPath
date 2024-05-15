import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:starpath/misc/constants.dart';

class Votes extends StatefulWidget {
  int likes, dislikes;
  String id_post;
  Votes({super.key, required this.likes, required this.dislikes, required this.id_post});

  @override
  State<Votes> createState() => _VotesState();
}

class _VotesState extends State<Votes> {
  bool pressedLike = false, pressedDislike = false;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Row(
        children: [
          GestureDetector(
              onTap: () async{
                setState(() {
                  if(!pressedLike){
                    if(pressedDislike){
                      pressedDislike = false;
                      widget.dislikes--;
                    }
                    pressedLike = true;
                    widget.likes++;
                  }else{
                    pressedLike = false;
                    widget.likes--;
                  }
                });
                await updateLikesAsync();
              },
              child: const Icon(Icons.arrow_upward_rounded)),
          Text("${widget.likes}"),
          GestureDetector(
              onTap: () async{
                setState(() {
                  if(!pressedDislike){
                    if(pressedLike){
                      pressedLike = false;
                      widget.likes--;
                    }
                    pressedDislike = true;
                    widget.dislikes++;
                  }else{
                    pressedDislike = false;
                    widget.dislikes--;
                  }
                });
                await updateLikesAsync();
              },
              child: const Icon(Icons.arrow_downward_rounded)),
          Text("${widget.dislikes}")
        ],
      ),
    );
  }
  Future<void> updateLikesAsync() async{
    await supabase
        .from("post")
        .update({
          'like': widget.likes,
          'dislike': widget.dislikes
        }).eq('id_post', widget.id_post);
  }
}