import 'package:flutter/material.dart';
import 'package:starpath/misc/constants.dart';

class UpperAppBar extends StatelessWidget {
  final List<Widget> content;
  const UpperAppBar({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return
      Expanded(
          flex: 1,
          child: Container(
              decoration: const BoxDecoration(
                  color: BUTTON_BAR_BACKGROUND,
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(30.0))),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: content,
                ),
              )
          )
      );
  }
}
