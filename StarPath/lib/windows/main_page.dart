import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:starpath/misc/constants.dart';
import 'package:starpath/model/PostData.dart';
import 'package:starpath/model/user.dart';
import 'package:starpath/model/user_data.dart';
import 'package:starpath/widgets/avatar_button.dart';
import 'package:starpath/widgets/camera_button.dart';
import 'package:starpath/widgets/post.dart';
import 'package:starpath/widgets/search_bar.dart';
import 'package:starpath/widgets/upper_app_bar.dart';
import 'package:starpath/windows/chat_list.dart';
import 'package:starpath/windows/event_main_page.dart';
import 'package:starpath/windows/explore_page.dart';
import 'package:starpath/windows/options.dart';
import 'package:supabase/supabase.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Future<List<PostData>> futurePost = getPostAsync();
  Future<UserData> userData = Future.value(UserData.empty());
  late String userId;
  @override
  void initState() {
    super.initState();
    userId = context.read<UserProvider>().user!.id;
    supabase
        .channel('post_upvotes_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'post',
          callback: (payload) {
            futurePost.then((value) {
              for (var post in value) {
                if (post.id_post == payload.newRecord['id_post']) {
                  setState(() {
                    post.like = payload.newRecord['like'];
                    post.dislike = payload.newRecord['dislike'];
                  });
                }
              }
            });
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    supabase.channel('post_upvotes_changes').unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    User user = context.watch<UserProvider>().user!;
    userData = getUserDataAsync(user.id);
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: BACKGROUND,
        body: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).viewPadding.top,
            ),
            UpperAppBar(content: [
              buildAvatarButton(user),
              const SerachBar(),
              const CameraButton()
            ]),
            Expanded(
                flex: 8,
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FutureBuilder(
                      future: futurePost,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          //print("hay ${snapshot.data!.length} datos");
                          return ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              return Post(postData: snapshot.data![index]);
                            },
                          );
                        }
                        return const Center(child: CircularProgressIndicator());
                      },
                    ))),
            Expanded(
                flex: 1,
                child: Container(
                  decoration: const BoxDecoration(
                      color: BUTTON_BAR_BACKGROUND,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(30.0))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const OptionsMainPage(),
                              ));
                        },
                        child: const Icon(Icons.settings),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: const Icon(Icons.mail),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ExplorePage(),
                              ));
                        },
                        child: const Icon(Icons.newspaper),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EventMainPage(),
                              ));
                        },
                        child: const Icon(Icons.calendar_month),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatListPage(),));
                        },
                        child: const Icon(Icons.chat),
                      ),
                    ],
                  ),
                ))
          ],
        ));
  }

  FutureBuilder<UserData> buildAvatarButton(User user) {
    return FutureBuilder(
      future: userData,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.username != 'vacio') {
          return AvatarButton(
            profilePictureFuture: getProfilePicture(user),
            user: snapshot.data!,
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Future<List<Map<String, dynamic>>> getProfilePicture(User user) async {
    var profilePicture;
    profilePicture = await supabase
        .from("user")
        .select("profile_picture")
        .eq("id_user", user.id);
    // print(profilePicture);
    return profilePicture;
  }
}

Future<List<PostData>> getPostAsync() async {
  List<PostData> postList = [];
  PostData post;
  var res = await supabase
      .from('post')
      .select("*")
      .match({'deleted': false}).order('created_at', ascending: false);
  if (res.isNotEmpty) {
    for (var data in res) {
      post = PostData();
      post.id_post = data['id_post'];
      post.id_user = await getPostUsernameAsync(data['id_user']);
      post.content = data['content'];
      post.description = data['description'];
      post.like = data['like'];
      post.dislike = data['dislike'];
      post.created_at = data['created_at'];

      postList.add(post);
    }
  }
  return postList;
}

Future<String> getPostUsernameAsync(String id_user) async {
  String userName = "error";
  var res = await supabase
      .from('user')
      .select("username")
      .match({'id_user': id_user});
  userName = res[0]['username'];
  return userName;
}

Future<UserData> getUserDataAsync(String id_user) async {
  UserData user = UserData.empty();
  var res = await supabase
      .from('user')
      .select("id_user, username, profile_picture, last_login")
      .match({'id_user': id_user});
  user.id_user = res.first['id_user'];
  user.username = res.first['username'];
  user.profile_picture = res.first['profile_picture'];
  user.followers = '0';

  var creationDate = DateTime.parse(res.first['last_login']);
  var currentDate = DateTime.now();

  if (creationDate.month == currentDate.month &&
      creationDate.day == currentDate.day) {
    // Realizar animación
  }

  return user;
}
