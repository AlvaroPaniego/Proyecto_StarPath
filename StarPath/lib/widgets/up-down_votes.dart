import 'package:flutter/material.dart';

class Votes extends StatefulWidget {
  int likes, dislikes;
  Votes({super.key, required this.likes, required this.dislikes});

  @override
  State<Votes> createState() => _VotesState();
}

class _VotesState extends State<Votes> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Row(
        children: [
          const Icon(Icons.arrow_upward_rounded),
          Text("${widget.likes}"),
          const Icon(Icons.arrow_downward_rounded),
          Text("${widget.dislikes}")
        ],
      ),
    );
  }
}