import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:starpath/misc/constants.dart';
import 'package:starpath/model/user.dart';
import 'package:starpath/model/user_data.dart';
import 'package:starpath/widgets/avatar_button.dart';
import 'package:starpath/widgets/follow_button.dart';
import 'package:supabase/supabase.dart';

class UserInfoCarousel extends StatelessWidget {
  UserData user;
  UserInfoCarousel({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    User loggedUser = context.watch<UserProvider>().user!;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25.0),
            color: BUTTON_BAR_BACKGROUND),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
          child: Row(
            children: [
              AvatarButton(
                  profilePictureFuture: getProfilePicture(user.id_user),
                  user: user,
              ),
              Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          user.username,
                          style: const TextStyle(
                              color: TEXT, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Seguidores: ${user.followers}",
                          style: const TextStyle(
                            color: TEXT,
                          ),
                        )
                      ],
                    ),
                  )),
              FollowButton(userData: user)
            ],
          ),
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> getProfilePicture(String id_user) async {
    var profilePicture;
    profilePicture = await supabase
        .from("user")
        .select("profile_picture")
        .eq("id_user", id_user);
    // print(profilePicture);
    return profilePicture;
  }
  Future<void> followUser(String loggedUserId, String userToFollow) async{

  }
}
