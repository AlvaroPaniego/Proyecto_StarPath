import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
  const EventMainPage({super.key});

  @override
  State<EventMainPage> createState() => _EventMainPageState();
}

class _EventMainPageState extends State<EventMainPage> {
  Future<List<EventData>> futureEvents = Future.value([EventData.empty()]);
  UserData userData = UserData.empty();
  int _selectedIndex = 0;
  double _selectedDistance = 30000; // 30 km default

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _widgetOptions = <Widget>[
      EventMainList(selectedDistance: _selectedDistance),
      // TodayEventList(),
      MyEventList()
    ];

    futureEvents = getEvents();
    User user = context.watch<UserProvider>().user!;
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
          /*BottomNavigationBarItem(
            icon: Icon(Icons.today),
            label: 'Hoy',
          ), */
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
            )),
            Expanded(
              flex: 0,
              child: PopupMenuButton<double>(
                icon: const Icon(Icons.filter_alt),
                onSelected: (double value) {
                  setState(() {
                    _selectedDistance = value;
                  });
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<double>>[
                  const PopupMenuItem<double>(
                    value: 3000,
                    child: Text('3 km'),
                  ),
                  const PopupMenuItem<double>(
                    value: 10000,
                    child: Text('5 km'),
                  ),
                  const PopupMenuItem<double>(
                    value: 30000,
                    child: Text('10 km'),
                  ),
                  const PopupMenuItem<double>(
                    value: 50000,
                    child: Text('30 km'),
                  ),
                  const PopupMenuItem<double>(
                    value: 100000,
                    child: Text('50 km'),
                  ),
                  const PopupMenuItem<double>(
                    value: 300000,
                    child: Text('100 km'),
                  ),
                ],
              ),
            ),
            Expanded(
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
            ),
          ]),
          Expanded(
            flex: 9,
            child: _widgetOptions.elementAt(_selectedIndex),
          ),
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
    List<EventData> eventList = [];
    EventData eventData;
    var res =
        await supabase.from('events').select().gte('time', DateTime.now());
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
