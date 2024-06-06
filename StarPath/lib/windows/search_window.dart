import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:starpath/misc/constants.dart';
import 'package:starpath/model/user_data.dart';
import 'package:starpath/widgets/back_arrow.dart';
import 'package:starpath/widgets/upper_app_bar.dart';
import 'package:starpath/widgets/user_info_carousel.dart';
import 'package:starpath/windows/main_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  Future<List<UserData>> futureUserList = Future.value([]);
  bool hasSearched = false;
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
            UpperAppBar(
                content: [
                  BackArrow(route: MaterialPageRoute(builder: (context) => const MainPage(),)),
                  searchBar(searchController)
                ]),
            Expanded(
                flex: 10,
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FutureBuilder(
                      future: futureUserList,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data!.isEmpty && !hasSearched) {
                            return const Center(
                              child: Text(
                                "Escribe para buscar un usuario",
                                style: TextStyle(color: TEXT),
                              ),
                            );
                          } else if (snapshot.data!.isEmpty && hasSearched) {
                            return const Center(
                              child: Text(
                                "No se ha encontrado ese usuario",
                                style: TextStyle(color: TEXT),
                              ),
                            );
                          } else {
                            return ListView.builder(
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) =>
                                    UserInfoCarousel(
                                        user: snapshot.data![index]));
                          }
                        }
                        return const Center(child: CircularProgressIndicator());
                      },
                    ))),
          ],
        ));
  }

  Widget searchBar(TextEditingController searchController) {
    return Flexible(
      flex: 5,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              decoration: const InputDecoration(
                  hintText: "Buscar",
                  border: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: FOCUS_ORANGE, width: 1.0))),
              controller: searchController,
              onTapOutside: (event) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
            ),
          ),
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
                setState(() {
                  if (searchController.text.isNotEmpty) {
                    hasSearched = true;
                    futureUserList = searchUsers(searchController.text.trim());
                  } else {
                    hasSearched = false;
                    futureUserList = Future.value([]);
                  }
                });
              },
              child: const Icon(Icons.search),
            ),
          )
        ],
      ),
    );
  }

  Future<List<UserData>> searchUsers(String user) async {
    List<UserData> userList = [];
    UserData userData = UserData.empty();
    var res = await supabase
        .from('user')
        .select('id_user, username, profile_picture, privacy')
        .ilike('username', '$user%');
    for (var user in res) {
      userData = UserData.empty();
      userData.id_user = user['id_user'];
      userData.username = user['username'];
      userData.profile_picture = user['profile_picture'];
      userData.followers = '0';
      userData.privacy = res.first['privacy'];
      userList.add(userData);
    }
    return userList;
  }
}
