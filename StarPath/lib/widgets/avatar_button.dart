import 'package:flutter/material.dart';
import 'package:starpath/model/user_data.dart';
import 'package:starpath/windows/user_page_temp.dart';
import 'package:starpath/windows/user_profile_page.dart';
import 'package:supabase/supabase.dart';

class AvatarButton extends StatefulWidget {
  Future<List<Map<String, dynamic>>> profilePictureFuture;
  UserData user = UserData.empty();
  AvatarButton({super.key, required this.profilePictureFuture, required this.user});
  AvatarButton.LogedUserPage({super.key, required this.profilePictureFuture});

  @override
  State<AvatarButton> createState() => _AvatarButtonState();
}

class _AvatarButtonState extends State<AvatarButton> {
  @override
  Widget build(BuildContext context) {

    return Flexible(
      flex: 1,
      child: GestureDetector(
        onTap: ()  async{
          if(widget.user.id_user != 'vacio'){
            //Para poder navegar a una ventana de ususario especifico
            Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfilePage(userData: widget.user,)));
          }
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(45.0),
          child: FutureBuilder(
            future: widget.profilePictureFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if(snapshot.data![0]["profile_picture"] == ""){
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
