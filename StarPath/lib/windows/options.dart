import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:starpath/misc/constants.dart';
import 'package:starpath/widgets/back_arrow.dart';
import 'package:starpath/widgets/upper_app_bar.dart';
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
        backgroundColor: BACKGROUND,
        body: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).viewPadding.top,
            ),
            const UpperAppBar(content: [BackArrow()]),
            Expanded(
              flex: 8,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: ListView(
                  children: [
                    option("Opciones de accesibilidad", const AccesibilityOptions())
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  Widget option(optionName, optionWidget) {
    return TextButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => optionWidget));
        },
        child: Text(optionName));
  }
}
