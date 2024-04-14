import 'package:flutter/material.dart';

class CameraButton extends StatelessWidget {
  const CameraButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 1,
      child: GestureDetector(
        onTap: () {

        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}