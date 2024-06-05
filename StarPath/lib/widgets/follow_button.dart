import 'dart:async';
import 'package:flutter/material.dart';
import 'package:starpath/misc/constants.dart';
import 'package:starpath/model/user_data.dart';
import 'package:starpath/model/events.dart';

class FollowButton extends StatefulWidget {
  UserData? userData = UserData.empty();
  EventData? eventData = EventData.empty();
  final String loggedId;
  FollowButton(
      {super.key, this.userData, this.eventData, required this.loggedId});

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  late Future<bool> hasFollowed;
  late bool isForUser;
  @override
  Widget build(BuildContext context) {
    // User loggedUser = context.watch<UserProvider>().user!;
    if (widget.userData != null) {
      hasFollowed =
          hasAlreadyFollowed(widget.loggedId, widget.userData!.id_user);
    } else if (widget.eventData != null) {
      hasFollowed =
          hasAlreadyFollowedEvent(widget.loggedId, widget.eventData!.idEvent);
    }
    isForUser = widget.userData != null;
    var text = isForUser ? 'Seguir' : 'Asistir';
    return Expanded(
        flex: 1,
        child: FutureBuilder(
          future: hasFollowed,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
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
                  child: Text(
                    text,
                    style: const TextStyle(
                        color: TEXT, fontWeight: FontWeight.bold),
                  ));
            } else if (snapshot.hasData) {
              return snapshot.data!
                  ? GestureDetector(
                      onTap: () async {
                        isForUser
                            ? await unfollowUser(
                                widget.loggedId, widget.userData!.id_user)
                            : await unfollowEvent(
                                widget.loggedId, widget.eventData!.idEvent);
                        setState(() {
                          setState(() {
                            if (widget.userData != null) {
                              hasFollowed = hasAlreadyFollowed(
                                  widget.loggedId, widget.userData!.id_user);
                            } else if (widget.eventData != null) {
                              hasFollowed = hasAlreadyFollowedEvent(
                                  widget.loggedId, widget.eventData!.idEvent);
                            }
                          });
                        });
                      },
                      child: Container(
                        color: Colors.green,
                        child: const Icon(Icons.check),
                      ),
                    )
                  : ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateColor.resolveWith((states) {
                          if (states.contains(MaterialState.selected)) {
                            return BUTTON_BACKGROUND_DISABLED;
                          }
                          return BUTTON_BACKGROUND;
                        }),
                      ),
                      onPressed: () async {
                        isForUser
                            ? await followUser(
                                widget.loggedId, widget.userData!.id_user)
                            : await followEvent(
                                widget.loggedId, widget.eventData!.idEvent);
                        setState(() {
                          if (widget.userData != null) {
                            hasFollowed = hasAlreadyFollowed(
                                widget.loggedId, widget.userData!.id_user);
                          } else if (widget.eventData != null) {
                            hasFollowed = hasAlreadyFollowedEvent(
                                widget.loggedId, widget.eventData!.idEvent);
                          }
                        });
                      },
                      child: Text(
                        text,
                        style: const TextStyle(
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
        ));
  }

  Future<void> followUser(String loggedUserId, String userToFollow) async {
    await supabase.from('followers').insert({
      'id_user_principal': loggedUserId,
      'id_user_secundario': userToFollow
    });
  }

  Future<void> unfollowUser(String loggedUserId, String userToFollow) async {
    var postgreQuery =
        'and(id_user_principal.eq.$loggedUserId,id_user_secundario.eq.$userToFollow)';
    await supabase.from('followers').delete().or(postgreQuery);
  }

  Future<void> followEvent(String loggedUserId, String idEvent) async {
    await supabase
        .from('event_followers')
        .insert({'id_user': loggedUserId, 'id_event': idEvent});
  }

  Future<void> unfollowEvent(String loggedUserId, String idEvent) async {
    var postgreQuery = 'and(id_user.eq.$loggedUserId,id_event.eq.$idEvent)';
    await supabase.from('event_followers').delete().or(postgreQuery);
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

  Future<bool> hasAlreadyFollowedEvent(String loggedId, String idEvent) async {
    bool isFollowing = false;
    var postgreQuery = 'and(id_user.eq.$loggedId,id_event.eq.$idEvent)';
    var res = await supabase.from('event_followers').count().or(postgreQuery);
    isFollowing = res == 1;
    return isFollowing;
  }
}
