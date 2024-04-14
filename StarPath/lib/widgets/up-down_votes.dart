import 'package:flutter/material.dart';

class Votes extends StatefulWidget {
  const Votes({super.key});

  @override
  State<Votes> createState() => _VotesState();
}

class _VotesState extends State<Votes> {
  int upvotes = 0, downvotes = 0;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Row(
        children: [
          const Icon(Icons.arrow_upward_rounded),
          Text("$upvotes"),
          const Icon(Icons.arrow_downward_rounded),
          Text("$downvotes")
        ],
      ),
    );
  }
}