import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:starpath/misc/constants.dart';
import 'package:starpath/model/user.dart';
import 'package:starpath/model/user_data.dart';
import 'package:supabase/supabase.dart';

class FollowButton extends StatefulWidget {
  final UserData userData;
  const FollowButton({super.key, required this.userData});

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  bool hasFollowed = false;
  @override
  Widget build(BuildContext context) {
    User loggedUser = context.watch<UserProvider>().user!;
    return Expanded(
        flex: 1,
        child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor:
              MaterialStateColor.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return BUTTON_BACKGROUND_DISABLED;
                }
                return BUTTON_BACKGROUND;
              }),
            ),
            onPressed: () async{
              await followUser(loggedUser.id, widget.userData.id_user);
              setState(() {
                hasFollowed = !hasFollowed;
              });
            },
            child: hasFollowed ? const Text(
              "Seguir",
              style:
              TextStyle(color: TEXT, fontWeight: FontWeight.bold),) :
                Container(
                  color: Colors.green,
                  child: const Icon(Icons.check),
                )

        )
    );
  }
  Future<void> followUser(String loggedUserId, String userToFollow) async{

  }
}
