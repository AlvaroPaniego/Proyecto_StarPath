import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:starpath/Services/file_chooser.dart';
import 'package:starpath/misc/constants.dart';
import 'package:starpath/model/files.dart';
import 'package:starpath/model/user.dart';
import 'package:supabase/supabase.dart';

class AvatarButton extends StatefulWidget {
  const AvatarButton({super.key});

  @override
  State<AvatarButton> createState() => _AvatarButtonState();
}

class _AvatarButtonState extends State<AvatarButton> {
  @override
  Widget build(BuildContext context) {
    User user = context.watch<UserProvider>().user!;
    var profilePictureFuture = getProfilePicture(user);

    return Flexible(
      flex: 1,
      child: GestureDetector(
        onTap: ()  async{
          await FileChooser.uploadContent(user, "pruebas", "user");
          setState(()  {
            profilePictureFuture = getProfilePicture(user);

          });
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(45.0),
          child: FutureBuilder(
            future: profilePictureFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data![0]["profile_picture"].isEmpty) {
                  // print("snapshot.toString() => ${snapshot.data![0]["profile_picture"]}");
                  return Image.asset("assets/images/placeholder-avatar.jpg");
                }
                // print("snapshot.toString() => ${snapshot.data![0]["profile_picture"]}");
                return Image.network(snapshot.data![0]["profile_picture"]);
              } else if (snapshot.hasError) {
                print("hay algun error: ${snapshot.error}");
                return CircleAvatar();
              }
              return Image.asset("assets/images/placeholder-avatar.jpg");
            },
          ),
        ),
      ),
    );
  }
  Future<List<Map<String, dynamic>>> getProfilePicture(User user) async {
    var profilePicture;
    profilePicture = await supabase
        .from("user")
        .select("profile_picture")
        .eq("id_user", user.id);
    // print(profilePicture);
    return profilePicture;
  }
}
