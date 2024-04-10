import 'package:flutter/material.dart';
import 'package:starpath/windows/options_accesibility.dart';

class OptionsMainPage extends StatefulWidget {
  const OptionsMainPage({super.key});

  @override
  State<OptionsMainPage> createState() => _OptionsMainPageState();
}

class _OptionsMainPageState extends State<OptionsMainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(padding: EdgeInsets.all(8),
          child: ListView(
          children: [
            option("Opciones de accesibilidad", AccesibilityOptions())
        ],
      ),
      )
    );
  }
  Widget option(optionName, optionWidget){
    return TextButton(onPressed: () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => optionWidget));
    }, child: Text(optionName));
  }
}
