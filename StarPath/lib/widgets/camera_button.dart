
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:starpath/model/user.dart';
import 'package:starpath/windows/content_upload.dart';
import 'package:supabase/supabase.dart';

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
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ContentUploadPage()));
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}