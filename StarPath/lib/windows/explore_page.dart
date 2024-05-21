import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:starpath/misc/constants.dart';
import 'package:starpath/model/user_data.dart';
import 'package:starpath/widgets/news.dart';
import 'package:starpath/widgets/upper_app_bar.dart';
import 'package:starpath/widgets/user_info_carousel.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  Future<List<UserData>> futureUser = getRandomUsers();
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
            const UpperAppBar(content: [BackButton()]),
            Expanded(
              flex: 2,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: FutureBuilder(
                    future: futureUser,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return CarouselSlider(
                            items: userInfo(snapshot.data!),
                            options: CarouselOptions(
                                autoPlay: true,
                                animateToClosest: true,
                                disableCenter: true,
                            )
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
            ),
            //Habra que cambiar el ListView por un ListView.builder para que las publicaciones se añadan dinamicamente
            Expanded(
                flex: 7,
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView(
                      children: const [
                        News(),
                        News(),
                        News(),
                        News(),
                      ],
                ))),
          ],
        )
    );
  }

  List<Widget> userInfo(List<UserData> info) {
    List<Widget> userInfo = [];
    for (var user in info) {
      userInfo.add(UserInfoCarousel(user: user));
    }
    return userInfo;
  }

}
Future<List<UserData>> getRandomUsers() async{
  List<UserData> userList = [];
  Random r = Random();
  int maxUsers = 6;
  var res = await supabase
      .from("user")
      .select("*");
  for (int i = 0; i < maxUsers; i++) {
    int randomUser = r.nextInt(res.length);
    res.removeAt(randomUser);
    userList.add(UserData(res[randomUser]['id_user'], res[randomUser]['username'], res[randomUser]['profile_picture'], '0'));
  }
  return userList;
}
