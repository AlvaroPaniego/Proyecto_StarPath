import 'package:flutter/material.dart';
import 'package:starpath/misc/constants.dart';

class News extends StatefulWidget {
  const News({super.key});

  @override
  State<News> createState() => _NewsState();
}

class _NewsState extends State<News> {
  String newsTitle = "Titulo";
  String fecha = "Fecha";
  String lorem = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed "
      "do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad "
      "minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip "
      "ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate "
      "velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint"
      " occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit "
      "anim id est laborum. ";
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 8.0),
      child: ExpansionTile(
        backgroundColor: BUTTON_BAR_BACKGROUND,
        collapsedIconColor: TEXT,
        collapsedBackgroundColor: BUTTON_BACKGROUND,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(newsTitle,
              style: const TextStyle(
                color: TEXT,
              ),
            ),
            Text(fecha,
              style: const TextStyle(
                color: TEXT,
              ),
            ),
          ],
        ),
        leading: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(45.0),
            child: Image.asset("assets/images/placeholder-avatar.jpg")
          ),
        ),
        children: [
          Text(lorem,
            style: const TextStyle(
              color: TEXT,
            ),
          ),
          Image.asset("assets/images/placeholder-image.jpg"),
          TextButton(
              onPressed: () {

              },
              child: const Text("Ver más",
              style: TextStyle(
                color: TEXT,
              )
            )
          ),
        ],
      ),
    );
  }
}
