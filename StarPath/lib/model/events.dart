import 'package:geolocator/geolocator.dart';

class EventData {
  String idEvent = 'vacio';
  String title = 'vacio';
  String eventDate = 'vacio';
  String description = 'vacio';
  String username = 'vacio';
  String asistants = 'vacio';
  String eventImage = 'vacio';
  double latitude = 0.0;
  double longitude = 0.0;

  EventData.empty();

  EventData({
    required this.idEvent,
    required this.title,
    required this.eventDate,
    required this.description,
    required this.username,
    required this.asistants,
    required this.eventImage,
    required this.latitude,
    required this.longitude,
  });

  static List<EventData> filterEventsByProximity(
      List<EventData> events, Position userPosition, double maxDistance) {
    return events.where((event) {
      double distance = Geolocator.distanceBetween(
        userPosition.latitude,
        userPosition.longitude,
        event.latitude,
        event.longitude,
      );
      print(
          'Latitud del evento: ${event.latitude}, Longitud del evento: ${event.longitude}');

      return distance <= maxDistance;
    }).toList();
  }
}
