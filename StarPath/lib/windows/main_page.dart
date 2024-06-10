import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
import 'package:starpath/windows/edit_profile_page.dart';
import 'package:starpath/windows/event_main_page.dart';
import 'package:starpath/windows/explore_page.dart';
import 'package:starpath/windows/login.dart';
import 'package:starpath/windows/options.dart';
import 'package:starpath/windows/search_window.dart';
import 'package:starpath/windows/user_profile_page.dart';
import 'package:starpath/windows/wiki_page.dart';
import 'package:supabase/supabase.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late Future<List<PostData>> futurePost;
  late Future<UserData> userData;

  @override
  void initState() {
    super.initState();
    final userId = context.read<UserProvider>().user!.id;
    futurePost = getPostAsync();
    userData = getUserDataAsync(userId);
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
    final user = context.watch<UserProvider>().user!;
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
              buildAvatarButton(),
              Expanded(
                flex: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5.0),
                      child: Image.asset('assets/images/logo.png'),
                    ),
                    const Text(
                      'STARPATH',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                    )
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SearchPage(),
                      ),
                      (route) => false,
                    );
                  },
                  child: const Icon(Icons.search),
                ),
              )
            ],
          ),
          Expanded(
            flex: 8,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FutureBuilder<List<PostData>>(
                future: futurePost,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return Post(postData: snapshot.data![index]);
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              decoration: const BoxDecoration(
                color: BUTTON_BAR_BACKGROUND,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const CameraButton(),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WikiPage(),
                        ),
                      );
                    },
                    child: const Icon(Icons.account_balance),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ExplorePage(),
                        ),
                      );
                    },
                    child: const Icon(Icons.newspaper),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EventMainPage(),
                        ),
                      );
                    },
                    child: const Icon(Icons.calendar_month),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChatListPage(),
                        ),
                      );
                    },
                    child: const Icon(Icons.chat),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildAvatarButton() {
    return Expanded(
      flex: 1,
      child: PopupMenuButton(
        position: PopupMenuPosition.under,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(45.0),
          child: FutureBuilder<UserData>(
            future: userData,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!.profile_picture == "") {
                  return Image.asset("assets/images/placeholder-avatar.jpg");
                }
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditProfilePage(userData: snapshot.data!),
                      ),
                    ).then((_) {
                      setState(() {
                        futurePost = getPostAsync();
                      });
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(snapshot.data!.profile_picture),
                      ),
                    ),
                  ),
                );
              } else if (snapshot.hasError) {
                return Image.asset("assets/images/placeholder-avatar.jpg");
              }
              return Image.asset("assets/images/placeholder-avatar.jpg");
            },
          ),
        ),
        itemBuilder: (context) => <PopupMenuEntry>[
          PopupMenuItem(
            child: FutureBuilder<UserData>(
              future: userData,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditProfilePage(userData: snapshot.data!),
                      ),
                    ),
                    child: const Text('Editar perfil'),
                  );
                }
                return const Text('Editar perfil');
              },
            ),
          ),
          PopupMenuItem(
              child: FutureBuilder<UserData>(
            future: userData,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return GestureDetector(
                    onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                UserProfilePage(userData: snapshot.data!),
                          ),
                        ),
                    child: const Text('Ver perfil'));
              }
              return const Text('Ver perfil');
            },
          )),
          PopupMenuItem(
            child: GestureDetector(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Login()),
                  (Route<dynamic> route) => false,
                );
              },
              child: const Text("Cerrar sesion"),
            ),
          ),
        ],
      ),
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
      .select("id_user, username, profile_picture, last_login, privacy")
      .match({'id_user': id_user});
  user.id_user = res.first['id_user'];
  user.username = res.first['username'];
  user.profile_picture = res.first['profile_picture'];
  user.followers = '0';
  user.privacy = res.first['privacy'];

  var creationDate = DateTime.parse(res.first['last_login']);
  var currentDate = DateTime.now();

  if (creationDate.month == currentDate.month &&
      creationDate.day == currentDate.day) {
    // Realizar animación
  }

  return user;
}
