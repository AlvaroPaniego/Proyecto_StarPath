import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:starpath/misc/constants.dart';
import 'package:starpath/model/events.dart';
import 'package:starpath/model/user.dart';
import 'package:starpath/model/user_data.dart';
import 'package:starpath/widgets/back_arrow.dart';
import 'package:starpath/widgets/event.dart';
import 'package:starpath/widgets/upper_app_bar.dart';
import 'package:starpath/windows/user_profile_page.dart';
import 'package:supabase/supabase.dart';

class UserEventList extends StatefulWidget {
  final UserData userData;
  const UserEventList({super.key, required this.userData});

  @override
  State<UserEventList> createState() => _UserEventListState();
}

class _UserEventListState extends State<UserEventList> {
  Future<List<EventData>> futureEvents = Future.value([EventData.empty()]);
  @override
  Widget build(BuildContext context) {
    User user = context.watch<UserProvider>().user!;
    futureEvents = getEvents(widget.userData);
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: BACKGROUND,
        body: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).viewPadding.top,
            ),
            UpperAppBar(content: [
              BackArrow(
                  route: MaterialPageRoute(
                    builder: (context) => UserProfilePage(userData: widget.userData),
                  )),
              const Expanded(
                  flex: 3,
                  child: Text('EVENTOS',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0
                      )
                  )
              ),
              const SizedBox(width: 40.0,)
            ]),
            Expanded(
                flex: 9,
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FutureBuilder(
                      future: futureEvents,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data!.isEmpty) {
                            return const Center(
                                child: Text(
                                  'No has creado ningún evento.',
                                  style: TextStyle(color: TEXT),
                                ));
                          }
                          return ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              return Event(
                                eventData: snapshot.data![index],
                                canEdit: widget.userData.id_user == user.id,
                              );
                            },
                          );
                        }
                        return const Center(child: CircularProgressIndicator());
                      },
                    )
                )
            )
          ],
        )
    );
  }
  Future<UserData> getUserDataAsync(String id_user) async {
    UserData user = UserData.empty();
    var res = await supabase
        .from('user')
        .select("id_user, username, profile_picture")
        .match({'id_user': id_user});
    user.id_user = res.first['id_user'];
    user.username = res.first['username'];
    user.profile_picture = res.first['profile_picture'];
    user.followers = '0';
    return user;
  }

  Future<List<EventData>> getEvents(UserData user) async {
    List<EventData> eventList = [];
    EventData eventData;
    DateFormat format = DateFormat.yMd();

    var res =
    await supabase.rpc('getuserevents', params: {'idloggeduser': user.id_user});
    for (var event in res) {
      var resFollowers = await supabase
          .from('event_followers')
          .count()
          .eq('id_event', event['id']);
      var asistants = resFollowers.toString();
      eventData = EventData(
        idEvent: event['id'].toString(),
        title: event['title'],
        eventDate: format.format(DateTime.parse(event['time'])),
        description: event['description'],
        username: event['name_user'],
        asistants: asistants.toString(),
        eventImage: event['event_image'] ?? 'vacio',
        latitude: event['latitude'] ?? 0.0,
        longitude: event['longitude'] ?? 0.0,
      );
      eventList.add(eventData);
    }
    return eventList;
  }
}
