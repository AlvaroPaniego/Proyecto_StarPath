import 'package:flutter/material.dart';
import 'package:starpath/windows/content_upload.dart';

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
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ContentUploadPage()));
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
