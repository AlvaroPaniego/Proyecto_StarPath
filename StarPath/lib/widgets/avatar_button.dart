import 'package:flutter/material.dart';

class AvatarButton extends StatelessWidget {
  const AvatarButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 1,
      child: GestureDetector(
        onTap: () {

        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(45.0),
          child: Image.asset("assets/images/placeholder-avatar.jpg"),
        ),
      ),
    );
  }
}