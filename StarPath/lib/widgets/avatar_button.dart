import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:starpath/misc/constants.dart';
import 'package:starpath/model/profile_picture_manager.dart';
import 'package:starpath/model/user.dart';
import 'package:supabase/supabase.dart';

class AvatarButton extends StatefulWidget {
  Future<List<Map<String, dynamic>>> profilePictureFuture;
  AvatarButton({super.key, required this.profilePictureFuture});

  @override
  State<AvatarButton> createState() => _AvatarButtonState();
}

class _AvatarButtonState extends State<AvatarButton> {
  @override
  Widget build(BuildContext context) {
    //User user = context.watch<UserProvider>().user!;
    ProfilePictureManager profilePictureManager = ProfilePictureManager();

    return Flexible(
      flex: 1,
      child: GestureDetector(
        onTap: () async {
          //await profilePictureManager.uploadContent(user, "", "");
          setState(() {
            //widget.profilePictureFuture = getProfilePicture(user);
          });
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(45.0),
          child: FutureBuilder(
            future: widget.profilePictureFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data![0]["profile_picture"] == "") {
                  return Image.asset("assets/images/placeholder-avatar.jpg");
                }
                return Image.network(snapshot.data![0]["profile_picture"]);
              } else if (snapshot.hasError) {
                return Image.asset("assets/images/placeholder-avatar.jpg");
              }
              return Image.asset("assets/images/placeholder-avatar.jpg");
            },
          ),
        ),
      ),
    );
  }
}
