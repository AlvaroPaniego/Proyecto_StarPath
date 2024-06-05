import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:starpath/misc/constants.dart';
import 'package:starpath/model/user.dart';
import 'package:starpath/model/PostData.dart';
import 'package:starpath/model/user_data.dart';
import 'package:starpath/widgets/avatar_button.dart';
import 'package:starpath/widgets/back_arrow.dart';
import 'package:starpath/widgets/follow_button.dart';
import 'package:starpath/widgets/post.dart';
import 'package:starpath/widgets/upper_app_bar.dart';
import 'package:starpath/windows/ChatPage.dart';
import 'package:starpath/windows/comment_page.dart';
import 'package:starpath/windows/edit_profile_page.dart';
import 'package:starpath/windows/main_page.dart';
import 'package:supabase/supabase.dart';

class UserProfilePage extends StatefulWidget {
  final UserData userData;

  const UserProfilePage({Key? key, required this.userData}) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late Future<Map<String, dynamic>> _profileFuture;
  late Future<List<PostData>> _postsFuture;
  late Future<List<Map<String, dynamic>>> _avatarFuture;
  late Future<String> _followersFuture = Future.value("");

  @override
  void initState() {
    super.initState();
    _profileFuture = getProfile(widget.userData.id_user);
    _postsFuture = getPostAsync(widget.userData.id_user);
    _avatarFuture = getProfilePicture(widget.userData.id_user);
    _followersFuture = getFollowers(widget.userData.id_user);
  }

  void _showEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EditProfilePage(
              userData: widget.userData)), // Pasar el argumento userData
    );
  }

  @override
  Widget build(BuildContext context) {
    User user = context.watch<UserProvider>().user!;
    return Scaffold(
      backgroundColor: BACKGROUND,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: MediaQuery.of(context).viewPadding.top,
          ),
          UpperAppBar(content: [
            BackArrow(route: MaterialPageRoute(builder: (context) => const MainPage(),)),
            Text('Perfil de ${widget.userData.username}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
            const SizedBox(width: 40,)
          ]),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: FutureBuilder<Map<String, dynamic>>(
                future: _profileFuture,
                builder: (context, profileSnapshot) {
                  if (profileSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (profileSnapshot.hasError) {
                    return const Center(child: Text('Error al cargar el perfil'));
                  } else {
                    final profileData = profileSnapshot.data ?? {};
                    final imageUrl = profileData['profile_picture'] as String?;
                    final bio = profileData['bio'] as String?;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AvatarButton.LogedUserPage(
                                profilePictureFuture: _avatarFuture,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: FutureBuilder(future: _followersFuture, builder: (context, snapshot) {
                                  if(snapshot.hasData && snapshot.data!.isNotEmpty){
                                    return Text('Seguidores: ${snapshot.data!}', style: const TextStyle(color: TEXT),);
                                  }
                                  return const Text('Seguidores:  ', style: TextStyle(color: TEXT),);
                                },)
                              )
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Biografía',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: TEXT
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  bio ?? '',
                                  style: const TextStyle(fontSize: 16, color: TEXT),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ),
          user.id != widget.userData.id_user ? Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Flexible(
                  flex: 1,
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ChatPage(receiverUser: widget.userData),
                            ));
                      },
                      style: const ButtonStyle(
                          backgroundColor:
                              MaterialStatePropertyAll(BUTTON_BACKGROUND)),
                      child: const Text(
                        "Enviar mensaje",
                        style: TextStyle(color: TEXT),
                      )),
                ),
                FollowButton(loggedId: user.id, userData: widget.userData,)
              ],
            ),
          )
          : SizedBox(),
          Expanded(
            flex: 7,
            child: FutureBuilder<List<PostData>>(
              future: _postsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(
                      child: Text('Error al cargar las publicaciones'));
                } else {
                  final posts = snapshot.data ?? [];
                  return GridView.builder(
                    itemCount: posts.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
                    itemBuilder: (context, index) => postPreview(posts[index], context),
                  );
                  //   ListView.builder(
                  //   itemCount: posts.length,
                  //   itemBuilder: (context, index) {
                  //     return Post(postData: posts[index]);
                  //   },
                  // );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> getProfile(String userId) async {
    var profile = await supabase
        .from("user")
        .select("id_user, username, bio, profile_picture")
        .eq("id_user", userId)
        .single();
    return profile;
  }

  Future<List<Map<String, dynamic>>> getProfilePicture(String userId) async {
    var profilePicture = await supabase
        .from("user")
        .select("profile_picture")
        .eq("id_user", userId);
    return profilePicture;
  }

  Future<List<PostData>> getPostAsync(String userId) async {
    List<PostData> postList = [];
    PostData post;
    var res = await supabase
        .from('post')
        .select("*")
        .match({'id_user': userId}).order('created_at', ascending: false);
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
    var res = await supabase
        .from('user')
        .select("username")
        .match({'id_user': id_user});
    return res[0]['username'] as String;
  }
  Future<String> getFollowers(String user) async{
    String followers = '';
    var res = await supabase.from('followers').count().eq('id_user_secundario', user);
    followers = res.toString();
    print(followers);
    return followers;
  }
}
Widget postPreview(PostData postData, context){
  bool hasValidImage = postData.content.isNotEmpty;
  return GestureDetector(
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CommentPage(post: postData, hasReturnToMain: false,),)),
    child: Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
            image: NetworkImage(postData.content)
        )
      ),
    ),
  );
}
