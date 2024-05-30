import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starpath/model/user.dart';
import 'package:starpath/windows/login.dart';
import 'package:starpath/windows/wiki_page.dart';

//1234,,._
SharedPreferences? prefs;

void main() async {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => UserProvider(),
        )
      ],
      child:
          const MaterialApp(debugShowCheckedModeBanner: false, home: Login()),
    );
  }
}
