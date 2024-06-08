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
    User user = context.watch<UserProvider>().user!;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FutureBuilder(
        future: Future.wait([_currentPosition]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final userPosition = snapshot.data![0] as Position?;
            if (userPosition == null) {
              return const Center(
                child: Text(
                  'No se pudo obtener la posición del usuario.',
                  style: TextStyle(color: TEXT),
                ),
              );
            }
            final futureEvents = getEvents(_currentPosition, user.id);

            return FutureBuilder(
              future: futureEvents,
              builder: (context, AsyncSnapshot<List<EventData>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final events = snapshot.data!;
                  final nearbyEvents = EventData.filterEventsByProximity(
                      events, userPosition, 3000); // 3km

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
                      return Event(
                        eventData: nearbyEvents[index],
                        canEdit: false,
                        userPosition: userPosition,
                      );
                    },
                  );
                }
              },
            );
          }
        },
      ),
    );
  }

  Future<List<EventData>> getEvents(
    Future<Position> userPositionFuture,
    String userId,
  ) async {
    List<EventData> eventList = [];
    EventData eventData;
    var date = DateTime.now();
    var dateToday = DateTime(date.year, date.month, date.day);
    var userPosition = await userPositionFuture;

    var eventsRes = await supabase
        .from('events')
        .select('id, time, title, description, name_user, event_image')
        .filter('time', 'gte', dateToday);

    DateFormat format = DateFormat.yMd();
    for (var event in eventsRes ?? []) {
      var locationRes = await supabase
          .from('event_location')
          .select('latitude, longitude')
          .filter('id', 'eq', event['id']);

      // Si la consulta va guay combinar info del evento y la ubicación
      if (locationRes.isNotEmpty) {
        var locationData = locationRes[0];
        eventData = EventData(
          idEvent: event['id'].toString(),
          username: event['name_user'],
          description: event['description'],
          title: event['title'],
          eventDate: format.format(DateTime.parse(event['time'])),
          eventImage: event['event_image'] ?? 'vacio',
          asistants: '0',
          latitude: locationData['latitude'],
          longitude: locationData['longitude'],
        );

        eventList.add(eventData);
      } else {
        print('El evento no tiene localización');
      }
    }
    return eventList;
  }
}
