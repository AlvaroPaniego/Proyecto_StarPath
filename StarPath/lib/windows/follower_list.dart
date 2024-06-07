import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:starpath/misc/constants.dart';
import 'package:starpath/model/user_data.dart';
import 'package:starpath/widgets/back_arrow.dart';
import 'package:starpath/widgets/upper_app_bar.dart';
import 'package:starpath/widgets/user_info_carousel.dart';
import 'package:starpath/windows/user_profile_page.dart';

class FollowersListPage extends StatefulWidget {
  final UserData userData;
  const FollowersListPage({super.key, required this.userData});

  @override
  State<FollowersListPage> createState() => _FollowersListPageState();
}

class _FollowersListPageState extends State<FollowersListPage> {
  Future<List<UserData>> futureUserList = Future.value([]);
  @override
  Widget build(BuildContext context) {
    futureUserList = getUsers(widget.userData.id_user);
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
                  BackArrow(route: MaterialPageRoute(builder: (context) => UserProfilePage(userData: widget.userData,))),
                  const Text('Seguidores', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                  const SizedBox(width: 50,)
                ]),
            Expanded(
                flex: 10,
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FutureBuilder(
                      future: futureUserList,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data!.isEmpty) {
                            return const Center(
                              child: Text(
                                "Todavia no tienes ningún seguidor",
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
        )
    );
  }
  Future<List<UserData>> getUsers(String idUser) async {
    List<UserData> userList = [];
    UserData userData = UserData.empty();
    var resIdFollowers = await supabase
        .from('followers')
        .select('id_user_principal')
        .eq('id_user_secundario', idUser);
    for(var idFollower in resIdFollowers) {
      userData = await getUserDataAsync(idFollower['id_user_principal']);
      userList.add(userData);
    }
    return userList;
  }
  Future<UserData> getUserDataAsync(String id_user) async {
    UserData user = UserData.empty();
    var res = await supabase
        .from('user')
        .select("id_user, username, profile_picture, last_login, privacy")
        .match({'id_user': id_user});
    user.id_user = res.first['id_user'];
    user.username = res.first['username'];
    user.profile_picture = res.first['profile_picture'];
    user.followers = '0';
    user.privacy = res.first['privacy'];
    return user;
  }
}

