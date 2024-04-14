
import 'package:flutter/material.dart';
import 'package:starpath/misc/constants.dart';
import 'package:starpath/widgets/avatar_button.dart';
import 'package:starpath/widgets/camera_button.dart';
import 'package:starpath/widgets/post.dart';
import 'package:starpath/widgets/search_bar.dart';
import 'package:starpath/widgets/upper_app_bar.dart';
import 'package:starpath/windows/options.dart';

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
            SizedBox(
              height: MediaQuery.of(context).viewPadding.top,
            ),
             const UpperAppBar(content: [
                  AvatarButton(),
                  SerachBar(),
                  CameraButton()
                ]),

            //Habra que cambiar el ListView por un ListView.builder para que las publicaciones se añadan dinamicamente
            Expanded(flex: 8,child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                children: const [
                  Post(),
                  Post(),
                  Post(),
                  Post(),
                  Post(),
                  Post(),
                ],
              ),
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
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const OptionsMainPage(),));
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





