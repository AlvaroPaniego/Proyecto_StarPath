import 'package:flutter/material.dart';
import 'package:starpath/misc/constants.dart';

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
          Expanded(
            flex: 1,
            child: Container(
              decoration: const BoxDecoration(
                  color: BUTTON_BAR_BACKGROUND,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(30.0))
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () {

                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(45.0),
                          child: IconButton(onPressed: () {
                            Navigator.pop(context);
                          }, icon: const Icon(Icons.arrow_back)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
