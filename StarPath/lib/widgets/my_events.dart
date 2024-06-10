import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:starpath/misc/constants.dart';
import 'package:starpath/model/events.dart';
import 'package:starpath/model/user.dart';
import 'package:starpath/model/user_data.dart';
import 'package:supabase/supabase.dart';
import 'package:starpath/widgets/event.dart';

class MyEventList extends StatefulWidget {
  const MyEventList({Key? key}) : super(key: key);

  @override
  State<MyEventList> createState() => _MyEventListState();
}

class _MyEventListState extends State<MyEventList> {
  late Future<List<EventData>> futureEvents;
  late UserData userData = UserData.empty();

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>().user!;
    futureEvents = getEvents(user);
    getUserDataAsync(user.id).then((value) {
      setState(() {
        userData = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FutureBuilder<List<EventData>>(
        future: futureEvents,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No has creado ningún evento.',
                style: TextStyle(color: TEXT),
              ),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return Event(
                  canShowLocation: false,
                  eventData: snapshot.data![index],
                  canEdit: true,
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<UserData> getUserDataAsync(String id_user) async {
    UserData user = UserData.empty();
    var res = await supabase
        .from('user')
        .select("id_user, username, profile_picture")
        .match({'id_user': id_user});
    if (res.isNotEmpty) {
      user.id_user = res.first['id_user'];
      user.username = res.first['username'];
      user.profile_picture = res.first['profile_picture'];
      user.followers = '0';
    }
    return user;
  }

  Future<List<EventData>> getEvents(User user) async {
    List<EventData> eventList = [];
    DateFormat format = DateFormat.yMd();

    var res =
        await supabase.rpc('getuserevents', params: {'idloggeduser': user.id});
    for (var event in res) {
      var resFollowers = await supabase
          .from('event_followers')
          .count()
          .eq('id_event', event['id']);
      var asistants = resFollowers.toString();
      var locationRes = await supabase
          .from('event_location')
          .select('latitude, longitude')
          .eq('id', event['id']);
      if (locationRes.isNotEmpty) {
        var locationData = locationRes.first;
        eventList.add(EventData(
          idEvent: event['id'].toString(),
          title: event['title'],
          eventDate: format.format(DateTime.parse(event['time'])),
          description: event['description'],
          username: event['name_user'],
          asistants: asistants,
          eventImage: event['event_image'] ?? 'vacio',
          latitude: locationData['latitude'] ?? 0.0,
          longitude: locationData['longitude'] ?? 0.0,
        ));
      } else {
        print('El evento no tiene localización');
      }
    }
    return eventList;
  }
}
