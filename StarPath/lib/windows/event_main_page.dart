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
import 'package:starpath/widgets/event_list.dart';
import 'package:starpath/widgets/my_events.dart';
import 'package:starpath/widgets/search_bar.dart';
import 'package:starpath/widgets/today_event_list.dart';
import 'package:starpath/widgets/upper_app_bar.dart';
import 'package:starpath/windows/create_event.dart';
import 'package:starpath/windows/main_page.dart';
import 'package:supabase/supabase.dart';

class EventMainPage extends StatefulWidget {
  const EventMainPage({Key? key});

  @override
  State<EventMainPage> createState() => _EventMainPageState();
}

class _EventMainPageState extends State<EventMainPage> {
  Future<List<EventData>> futureEvents = Future.value([EventData.empty()]);
  UserData userData = UserData.empty();
  int _selectedIndex = 0;
  static const List<Widget> _widgetOptions = <Widget>[
    EventMainList(),
    TodayEventList(),
    MyEventList()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final futureEvents = getEvents();
    final user = context.watch<UserProvider>().user!;
    getUserDataAsync(user.id).then((value) => userData = value);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: BACKGROUND,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Buscar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.today),
            label: 'Hoy',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Mis eventos',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).viewPadding.top,
          ),
          UpperAppBar(content: [
            BackArrow(
              route: MaterialPageRoute(
                builder: (context) => const MainPage(),
              ),
            ),
            const Expanded(
              flex: 3,
              child: Text(
                'EVENTOS',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateEventPage(),
                    ),
                  );
                },
                child: const Icon(Icons.add),
              ),
            )
          ]),
          Expanded(flex: 9, child: _widgetOptions.elementAt(_selectedIndex))
        ],
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
    final eventList = <EventData>[];
    final res =
        await supabase.from('events').select().gte('time', DateTime.now());
    final format = DateFormat.yMd();
    for (var event in res ?? []) {
      eventList.add(EventData(
        idEvent: event['id'].toString(),
        username: event['name_user'],
        description: event['description'],
        title: event['title'],
        eventDate: format.format(DateTime.parse(event['time'])),
        eventImage: event['event_image'] ?? 'vacio',
        asistants:
            '0', // Asignar un valor por defecto para el parámetro asistants
        latitude: 0.0,
        longitude: 0.0,
      ));
    }

    return eventList;
  }
}
