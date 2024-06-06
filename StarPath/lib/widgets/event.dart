import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:starpath/misc/constants.dart';
import 'package:starpath/model/events.dart';
import 'package:starpath/model/user.dart';
import 'package:starpath/widgets/follow_button.dart';
import 'package:starpath/windows/edit_event.dart';
import 'package:supabase/supabase.dart';
import 'package:geolocator/geolocator.dart';

class Event extends StatefulWidget {
  final EventData eventData;
  final bool canEdit;
  final Position? userPosition;
  const Event({
    Key? key,
    required this.eventData,
    required this.canEdit,
    this.userPosition,
  });

  @override
  State<Event> createState() => _EventState();
}

class _EventState extends State<Event> {
  Future<String> futureAsistant = Future.value("vacio");

  @override
  void initState() {
    futureAsistant = getEventsAsistants(widget.eventData.idEvent);
    super.initState();
    // Suscribirse a los cambios de asistentes
    supabase
        .channel('asistant_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'event_followers',
          callback: (payload) {
            setState(() {
              futureAsistant = getEventsAsistants(widget.eventData.idEvent);
            });
            print('en el callback');
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    // Cancelar la suscripción a los cambios de asistentes
    supabase.channel('asistant_changes').unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool hasValidImage = widget.eventData.eventImage != 'vacio';
    User user = context.watch<UserProvider>().user!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: EVENT_BACKGROUND,
              borderRadius: BorderRadius.circular(25.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  flex: 2,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25.0),
                    child: hasValidImage
                        ? Image.network(widget.eventData.eventImage)
                        : Image.asset("assets/images/placeholder-image.jpg"),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.eventData.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.eventData.username,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w300),
                            ),
                            Text(widget.eventData.eventDate.toString())
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                flex: 2,
                                //widget.eventData.description
                                child: Text(widget.eventData.description)),
                            widget.canEdit
                                ? Expanded(
                                    child: ElevatedButton(
                                        style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    BUTTON_BACKGROUND)),
                                        onPressed: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    EditEventPage(
                                                        eventData:
                                                            widget.eventData))),
                                        child: const Text(
                                          'Editar',
                                          style: TextStyle(color: TEXT),
                                        )))
                                : FollowButton(
                                    loggedId: user.id,
                                    eventData: widget.eventData,
                                  )
                          ],
                        ),
                        FutureBuilder(
                          future: futureAsistant,
                          builder: (context, snapshot) {
                            if (snapshot.hasData && snapshot.data != 'vacio') {
                              return Text("Asistentes: ${snapshot.data}");
                            }
                            return const Text("Asistentes:");
                          },
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<String> getEventsAsistants(String idEvent) async {
    String asistants = '0';
    var res =
        await supabase.from('event_followers').count().eq('id_event', idEvent);
    asistants = res.toString();
    return asistants;
  }
}
