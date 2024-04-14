import 'package:flutter/material.dart';
import 'package:starpath/windows/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starpath/windows/main_page.dart';
import 'package:starpath/windows/options.dart';

SharedPreferences? prefs; // Variable global para SharedPreferences

void main() async {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainPage()
    );
  }
}
