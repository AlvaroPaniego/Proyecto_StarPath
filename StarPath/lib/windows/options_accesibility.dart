import 'package:flutter/material.dart';
import 'package:starpath/misc/constants.dart';
import 'package:starpath/widgets/back_arrow.dart';
import 'package:starpath/widgets/upper_app_bar.dart';

class AccesibilityOptions extends StatefulWidget {
  const AccesibilityOptions({super.key});

  @override
  State<AccesibilityOptions> createState() => _AccesibilityOptionsState();
}

class _AccesibilityOptionsState extends State<AccesibilityOptions> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BACKGROUND,
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).viewPadding.top,
          ),
          const UpperAppBar(content: [
                BackArrow()
              ],),
          //Habra que cambiar el ListView por un ListView.builder para que las publicaciones se añadan dinamicamente
          Expanded(flex: 8,child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: const [

              ],
            ),
          )
          ),
        ],
      ),
    );
  }
}