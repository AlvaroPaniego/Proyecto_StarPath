import 'dart:async';
import 'package:flutter/material.dart';
import 'package:starpath/misc/constants.dart';
import 'package:starpath/model/user_data.dart';

class FollowButton extends StatefulWidget {
  final UserData userData;
  final String loggedId;
  const FollowButton(
      {super.key, required this.userData, required this.loggedId});

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  late Future<bool> hasFollowed;
  @override
  Widget build(BuildContext context) {
    // User loggedUser = context.watch<UserProvider>().user!;
    hasFollowed = hasAlreadyFollowed(widget.loggedId, widget.userData.id_user);
    return Expanded(
        flex: 1,
        child: FutureBuilder(
          future: hasFollowed,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateColor.resolveWith((states) {
                      if (states.contains(MaterialState.selected)) {
                        return BUTTON_BACKGROUND_DISABLED;
                      }
                      return BUTTON_BACKGROUND;
                    }),
                  ),
                  onPressed: () {},
                  child: const Text(
                    "Seguir",
                    style: TextStyle(color: TEXT, fontWeight: FontWeight.bold),
                  ));
            } else if (snapshot.hasData) {
              return ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateColor.resolveWith((states) {
                      if (states.contains(MaterialState.selected)) {
                        return BUTTON_BACKGROUND_DISABLED;
                      }
                      return BUTTON_BACKGROUND;
                    }),
                  ),
                  onPressed: () async {
                    if(snapshot.data!){
                      await unfollowUser(widget.loggedId, widget.userData.id_user);
                    }else{
                      await followUser(widget.loggedId, widget.userData.id_user);
                    }
                    setState(() {
                      hasFollowed = hasAlreadyFollowed(widget.loggedId, widget.userData.id_user);
                    });
                  },
                  child: snapshot.data!
                      ? Container(
                          color: Colors.green,
                          child: const Icon(Icons.check),
                        )
                      : const Text(
                          "Seguir",
                          style: TextStyle(
                              color: TEXT, fontWeight: FontWeight.bold),
                        ));
            }
            return ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateColor.resolveWith((states) {
                    if (states.contains(MaterialState.selected)) {
                      return BUTTON_BACKGROUND_DISABLED;
                    }
                    return BUTTON_BACKGROUND;
                  }),
                ),
                onPressed: () {},
                child: const Text(
                  "Seguir",
                  style: TextStyle(color: TEXT, fontWeight: FontWeight.bold),
                ));
          },
        )
    );
  }

  Future<void> followUser(String loggedUserId, String userToFollow) async {
    await supabase.from('followers').insert({
      'id_user_principal': loggedUserId,
      'id_user_secundario': userToFollow
    });
  }
  Future<void>unfollowUser(String loggedUserId, String userToFollow) async{
    var postgreQuery =
        'and(id_user_principal.eq.$loggedUserId,id_user_secundario.eq.$userToFollow)';
    await supabase.from('followers').delete().or(postgreQuery);
  }
  Future<bool> hasAlreadyFollowed(
      String loggedId, String userToFollowId) async {
    bool isFollowing = false;
    var postgreQuery =
        'and(id_user_principal.eq.$loggedId,id_user_secundario.eq.$userToFollowId)';
    var res = await supabase.from('followers').count().or(postgreQuery);
    isFollowing = res == 1;
    return isFollowing;
  }
}
