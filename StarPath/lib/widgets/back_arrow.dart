import 'package:flutter/material.dart';
import 'package:starpath/windows/main_page.dart';

class BackArrow extends StatelessWidget {
  final MaterialPageRoute route;
  const BackArrow({super.key, required this.route});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(45.0),
        child: IconButton(onPressed: () {
          Navigator.push(context, route);
        }, icon: const Icon(Icons.arrow_back)),
      ),
    );
  }
}
