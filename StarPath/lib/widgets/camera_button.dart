import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:starpath/Services/file_chooser.dart';
import 'package:starpath/misc/constants.dart';

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
          FileChooser.uploadContent();
          var user = supabase.auth.currentUser;
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}