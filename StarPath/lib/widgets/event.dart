import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:starpath/model/events.dart';
import 'package:starpath/model/user.dart';
import 'package:starpath/widgets/follow_button.dart';
import 'package:supabase/supabase.dart';

class Event extends StatefulWidget {
  final EventData eventData;
  const Event({super.key, required this.eventData});

  @override
  State<Event> createState() => _EventState();
}

class _EventState extends State<Event> {
  bool hasValidImage = false;
  @override
  Widget build(BuildContext context) {
    User user = context.watch<UserProvider>().user!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
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
                        ? Image.network(widget.eventData.username) // todavia no hay campo de imagen en la bd
                        : Image.asset("assets/images/placeholder-image.jpg"),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.eventData.title, style: const TextStyle(fontWeight: FontWeight.bold),),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(widget.eventData.username, style: const TextStyle(fontWeight: FontWeight.w300),),
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
                                child: Text(widget.eventData.description)
                            ),
                            FollowButton(loggedId: user.id, eventData: widget.eventData,)
                          ],
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
}
