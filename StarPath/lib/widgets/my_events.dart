import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:starpath/misc/constants.dart';
import 'package:starpath/model/events.dart';
import 'package:starpath/model/user.dart';
import 'package:starpath/model/user_data.dart';
import 'package:starpath/widgets/back_arrow.dart';
import 'package:starpath/widgets/event.dart';
import 'package:starpath/widgets/search_bar.dart';
import 'package:starpath/widgets/upper_app_bar.dart';
import 'package:starpath/windows/create_event.dart';
import 'package:starpath/windows/main_page.dart';
import 'package:supabase/supabase.dart';

class MyEventList extends StatefulWidget {
  const MyEventList({super.key});

  @override
  State<MyEventList> createState() => _EventMainPageState();
}

class _EventMainPageState extends State<MyEventList> {
  Future<List<EventData>> futureEvents = Future.value([EventData.empty()]);
  UserData userData = UserData.empty();
  @override
  Widget build(BuildContext context) {
    User user = context.watch<UserProvider>().user!;
    futureEvents = getEvents(user);
    getUserDataAsync(user.id).then((value) => userData = value);
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder(
          future: futureEvents,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if(snapshot.data!.isEmpty){
                return const Center(child: Text('No has creado ningún evento.', style: TextStyle(color: TEXT),));
              }
              //print("hay ${snapshot.data!.length} datos");
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return Event(eventData: snapshot.data![index], canEdit: true,);
                },
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ));
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
  Future<List<EventData>> getEvents(User user) async{
    List<EventData> eventList = [];
    EventData eventData;
    var res = await supabase.rpc('getuserevents', params: {'idloggeduser' : user.id});
    DateFormat format = DateFormat.yMd();
    for (var event in res) {
      eventData = EventData.empty();
      eventData.idEvent = event['id'].toString();
      eventData.username = event['name_user'];
      eventData.description = event['description'];
      eventData.title = event['title'];
      eventData.eventDate = format.format(DateTime.parse(event['time']));
      eventData.eventImage = event['event_image'] ?? 'vacio';
      eventData.asistants = '0';
      eventList.add(eventData);
    }
    return eventList;
  }
}
