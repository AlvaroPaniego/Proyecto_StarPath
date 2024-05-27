import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:starpath/misc/constants.dart';
import 'package:starpath/model/user.dart';
import 'package:starpath/model/user_data.dart';
import 'package:starpath/widgets/avatar_button.dart';
import 'package:starpath/widgets/follow_button.dart';
import 'package:supabase/supabase.dart';

class UserInfoCarousel extends StatefulWidget {
  final UserData user;
  const UserInfoCarousel({super.key, required this.user});

  @override
  State<UserInfoCarousel> createState() => _UserInfoCarouselState();
}

class _UserInfoCarouselState extends State<UserInfoCarousel> {
  Future<String> futureFollowers = Future.value("vacio");
  void initState() {
    futureFollowers = getFollowers(widget.user.id_user);
    super.initState();
    supabase
        .channel('followers_changes')
        .onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'followers',
      callback: (payload) {
        setState(() {
          futureFollowers = getFollowers(widget.user.id_user);
        });
        print('en el callback');
      },
    ).subscribe();
  }

  @override
  void dispose() {
    supabase.channel('followers_changes').unsubscribe();
    super.dispose();
  }
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
                  profilePictureFuture: getProfilePicture(widget.user.id_user),
                  user: widget.user,
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
                          widget.user.username,
                          style: const TextStyle(
                              color: TEXT, fontWeight: FontWeight.bold),
                        ),
                        FutureBuilder(future: futureFollowers, builder: (context, snapshot) {
                          if(snapshot.hasData){
                            if(snapshot.data != 'vacio'){
                              return Text(
                                "Seguidores: ${snapshot.data}",
                                style: const TextStyle(
                                  color: TEXT,
                                ),
                              );
                            }
                          }
                          return const Text(
                            "Seguidores:",
                            style: TextStyle(
                              color: TEXT,
                            ),
                          );
                        },)
                      ],
                    ),
                  )),
              FollowButton(userData: widget.user, loggedId: loggedUser.id,)
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

  Future<String> getFollowers(String user) async{
    String followers = '';
    var res = await supabase.from('followers').count().eq('id_user_secundario', user);
    followers = res.toString();
    print(followers);
    return followers;
  }
}
