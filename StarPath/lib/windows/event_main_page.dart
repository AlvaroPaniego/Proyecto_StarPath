import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:starpath/misc/constants.dart';
import 'package:starpath/model/events.dart';
import 'package:starpath/model/user.dart';
import 'package:starpath/model/user_data.dart';
import 'package:starpath/widgets/event.dart';
import 'package:starpath/widgets/search_bar.dart';
import 'package:starpath/widgets/upper_app_bar.dart';
import 'package:supabase/supabase.dart';

class EventMainPage extends StatefulWidget {
  const EventMainPage({super.key});

  @override
  State<EventMainPage> createState() => _EventMainPageState();
}

class _EventMainPageState extends State<EventMainPage> {
  Future<List<EventData>> futureEvents = Future.value([EventData.empty()]);
  UserData userData = UserData.empty();
  @override
  Widget build(BuildContext context) {
    futureEvents = getEvents();
    User user = context.watch<UserProvider>().user!;
    getUserDataAsync(user.id).then((value) => userData = value);
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: BACKGROUND,
        body: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).viewPadding.top,
            ),
            const UpperAppBar(
                content: [BackButton(), SerachBar()]),

            Expanded(
                flex: 8,
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FutureBuilder(
                      future: futureEvents,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          //print("hay ${snapshot.data!.length} datos");
                          return ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              return Event(eventData: snapshot.data![index]);
                            },
                          );
                        }
                        return const Center(child: CircularProgressIndicator());
                      },
                    ))),
            Expanded(
                flex: 1,
                child: Container(
                  decoration: const BoxDecoration(
                      color: BUTTON_BAR_BACKGROUND,
                      borderRadius:
                      BorderRadius.vertical(top: Radius.circular(30.0))),
                ))
          ],
        )
    );
  }
  Future<UserData> getUserDataAsync(String id_user) async{
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
  Future<List<EventData>> getEvents() async{
    List<EventData> eventList = [];
    EventData eventData;
    var res = await supabase.from('events').select().gte('time', DateTime.now());
    DateFormat format = DateFormat.yMd();
    for (var event in res) {
      eventData = EventData.empty();
      eventData.idEvent = event['id'].toString();
      eventData.username = event['name_user'];
      eventData.description = event['description'];
      eventData.title = event['title'];
      eventData.eventDate = format.format(DateTime.parse(event['time']));
      eventList.add(eventData);
    }
    return eventList;
  }
}
