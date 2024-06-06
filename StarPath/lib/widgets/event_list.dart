import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:starpath/misc/constants.dart';
import 'package:starpath/model/events.dart';
import 'package:starpath/model/user.dart';
import 'package:starpath/model/user_data.dart';
import 'package:starpath/widgets/event.dart';
import 'package:supabase/supabase.dart';

class EventMainList extends StatefulWidget {
  const EventMainList({Key? key}) : super(key: key);

  @override
  State<EventMainList> createState() => _EventMainPageState();
}

class _EventMainPageState extends State<EventMainList> {
  Future<List<EventData>> futureEvents = Future.value([EventData.empty()]);
  UserData userData = UserData.empty();
  late Future<Position> _currentPosition;

  @override
  void initState() {
    super.initState();
    _currentPosition = _determinePosition();
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error(
          'Los servicios de localización están deshabilitados.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Los permisos de localización fueron denegados.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Los permisos de localización fueron denegados permanentemente.');
    }

    // Obtener la posición del usuario
    var position = await Geolocator.getCurrentPosition();
    print('1 Obteniendo posición del usuario: $position');

    return position;
  }

  @override
  Widget build(BuildContext context) {
    futureEvents = getEvents();
    User user = context.watch<UserProvider>().user!;
    getUserDataAsync(user.id).then((value) => userData = value);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FutureBuilder(
        future: Future.wait([futureEvents, _currentPosition]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final events = snapshot.data![0] as List<EventData>;
            final userPosition = snapshot.data![1] as Position?;
            if (userPosition == null) {
              return const Center(
                child: Text(
                  'No se pudo obtener la posición del usuario.',
                  style: TextStyle(color: TEXT),
                ),
              );
            }
            final nearbyEvents = EventData.filterEventsByProximity(
                events, userPosition, 10000); // 10km

            if (nearbyEvents.isEmpty) {
              return const Center(
                  child: Text(
                'No hay eventos cercanos en la base de datos.',
                style: TextStyle(color: TEXT),
              ));
            }

            return ListView.builder(
              itemCount: nearbyEvents.length,
              itemBuilder: (context, index) {
                return Event(eventData: nearbyEvents[index], canEdit: false);
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
    user.id_user = res.first['id_user'];
    user.username = res.first['username'];
    user.profile_picture = res.first['profile_picture'];
    user.followers = '0';
    return user;
  }

  Future<List<EventData>> getEvents() async {
    List<EventData> eventList = [];
    EventData eventData;
    var date = DateTime.now();
    var dateToday = DateTime(date.year, date.month, date.day);
    var res = await supabase
        .from('events')
        .select()
        .gte('time', dateToday)
        .order('time', ascending: true);
    DateFormat format = DateFormat.yMd();
    for (var event in res) {
      eventData = EventData(
        idEvent: event['id'].toString(),
        username: event['name_user'],
        description: event['description'],
        title: event['title'],
        eventDate: format.format(DateTime.parse(event['time'])),
        eventImage: event['event_image'] ?? 'vacio',
        asistants: '0',
        latitude: event['latitude'],
        longitude: event['longitude'],
      );
      eventList.add(eventData);
    }
    return eventList;
  }
}
