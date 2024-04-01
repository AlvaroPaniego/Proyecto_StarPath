import 'package:flutter/material.dart';
import 'package:starpath/windows/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

SharedPreferences? prefs; // Variable global para SharedPreferences

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Para asegurarse de que SharedPreferences esté inicializado
  prefs = await initSharedPreferences();
  runApp(const MainApp());
}

Future<SharedPreferences> initSharedPreferences() async {
  return await SharedPreferences.getInstance();
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: Login());
  }
}
