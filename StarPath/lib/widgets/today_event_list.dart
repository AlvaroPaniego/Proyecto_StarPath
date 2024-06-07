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

class TodayEventList extends StatefulWidget {
  const TodayEventList({Key? key}) : super(key: key);

  @override
  State<TodayEventList> createState() => _TodayEventListState();
}

class _TodayEventListState extends State<TodayEventList> {
  late Future<List<EventData>> futureEvents;
  UserData userData = UserData.empty();
  late Future<Position?> _currentPosition;

  @override
  void initState() {
    super.initState();
    _currentPosition = _determinePosition();
  }

  Future<Position?> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Los servicios de localización están deshabilitados.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Los permisos de localización fueron denegados.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Los permisos de localización fueron denegados permanentemente.');
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user!;
    futureEvents = getEvents();

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
                events, userPosition, 3000); // 3km

            if (nearbyEvents.isEmpty) {
              return const Center(
                  child: Text(
                'No hay eventos planeados para hoy cercanos.',
                style: TextStyle(color: TEXT),
              ));
            }

            return ListView.builder(
              itemCount: nearbyEvents.length,
              itemBuilder: (context, index) {
                return Event(
                  eventData: nearbyEvents[index],
                  canEdit: false,
                  userPosition: userPosition,
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<List<EventData>> getEvents() async {
    final List<EventData> eventList = [];
    final date = DateTime.now();
    final dateToday = DateTime(date.year, date.month, date.day);
    final res = await supabase.from('events').select().eq('time', dateToday);
    final format = DateFormat.yMd();
    for (var event in res) {
      final eventData = EventData(
        idEvent: event['id'].toString(),
        username: event['name_user'],
        description: event['description'],
        title: event['title'],
        eventDate: format.format(DateTime.parse(event['time'])),
        eventImage: event['event_image'] ?? 'vacio',
        asistants: '0',
        latitude: event['latitude'] ?? 0.0,
        longitude: event['longitude'] ?? 0.0,
      );
      eventList.add(eventData);
    }
    return eventList;
  }
}
