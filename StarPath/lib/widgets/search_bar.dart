import 'package:flutter/material.dart';
import 'package:starpath/misc/constants.dart';
import 'package:starpath/windows/search_window.dart';

class SerachBar extends StatelessWidget {
  const SerachBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 5,
      child: GestureDetector(
        onTap: () => Navigator.push(
            context,
            PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const SearchPage(),
                reverseTransitionDuration: Duration.zero,
                transitionDuration: Duration.zero)),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: FOCUS_ORANGE,
              )),
          child: const Text('Buscar'),
        ),
      ),
    );
  }
}
