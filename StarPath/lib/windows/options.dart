import 'package:flutter/material.dart';
import 'package:starpath/misc/constants.dart';
import 'package:starpath/widgets/back_arrow.dart';
import 'package:starpath/widgets/upper_app_bar.dart';
import 'package:starpath/windows/login.dart'; // Importa la página de inicio de sesión

class OptionsMainPage extends StatefulWidget {
  const OptionsMainPage({Key? key}) : super(key: key);

  @override
  State<OptionsMainPage> createState() => _OptionsMainPageState();
}

class _OptionsMainPageState extends State<OptionsMainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BACKGROUND,
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).viewPadding.top,
          ),
          UpperAppBar(content: [BackArrow()]),
          Expanded(
            flex: 8,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: ListView(
                children: [
                  option("Cerrar Sesión", () {
                    // Cerrar sesión y navegar a la página de inicio de sesión
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => Login()),
                      (Route<dynamic> route) => false,
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget option(String optionName, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 10),
      child: ElevatedButton(
        onPressed: onTap,
        child: Text(
          optionName,
          style: TextStyle(color: Colors.black),
        ),
        style: ElevatedButton.styleFrom(
          //primary: BUTTON_BACKGROUND,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          padding: EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }
}
