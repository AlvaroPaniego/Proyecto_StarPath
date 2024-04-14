import 'package:flutter/material.dart';
import 'package:starpath/misc/constants.dart';

class SerachBar extends StatelessWidget {
  const SerachBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Expanded(
      flex: 5,
      child: TextField(
          style: TextStyle(color: TEXT),
          decoration: InputDecoration(hintText: "Buscar", border: OutlineInputBorder())
      ),
    );
  }
}