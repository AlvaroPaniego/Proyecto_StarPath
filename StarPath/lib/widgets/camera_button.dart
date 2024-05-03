
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:starpath/Services/file_chooser.dart';
import 'package:starpath/misc/constants.dart';
import 'package:starpath/model/user.dart';
import 'package:supabase/supabase.dart';

class CameraButton extends StatelessWidget {
  const CameraButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    User user = context.watch<UserProvider>().user!;
    return Flexible(
      flex: 1,
      child: GestureDetector(
        onTap: () {
          FileChooser.uploadContent(user, "prueba", "posts");
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}