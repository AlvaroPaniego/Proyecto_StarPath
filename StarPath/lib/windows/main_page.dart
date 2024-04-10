
import 'package:flutter/material.dart';
import 'package:starpath/misc/constants.dart';
import 'package:starpath/widgets/post.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: BACKGROUND,
        body: Column(
          children: [
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
                            child: Image.asset("assets/images/placeholder-avatar.jpg"),
                          ),
                        ),
                      ),
                      const Expanded(
                        flex: 5,
                        child: TextField(
                            style: TextStyle(color: TEXT),
                            decoration: InputDecoration(hintText: "Buscar", border: OutlineInputBorder())
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () {

                          },
                          child: const Icon(Icons.camera_alt),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            //Habra que cambiar el ListView por un ListView.builder para que las publicaciones se añadan dinamicamente
            Expanded(flex: 8,child: ListView(
              children: const [
                Post(),
                Post(),
                Post(),
                Post(),
                Post(),
                Post(),
              ],
            )
            ),
            Expanded(
                flex: 1,
                child: Container(
                  decoration: const BoxDecoration(
                      color: BUTTON_BAR_BACKGROUND,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(30.0))
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {

                        },
                        child: const Icon(Icons.settings),
                      ),
                      GestureDetector(
                        onTap: () {

                        },
                        child: const Icon(Icons.mail),
                      ),
                      GestureDetector(
                        onTap: () {

                        },
                        child: const Icon(Icons.calendar_month),
                      ),
                      GestureDetector(
                        onTap: () {

                        },
                        child: const Icon(Icons.chat),
                      ),
                    ],
                  ),
                )
            )
          ],
        )
    );
  }
}