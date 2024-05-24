import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:starpath/misc/constants.dart';
import 'package:starpath/model/user.dart';
import 'package:starpath/model/PostData.dart';
import 'package:starpath/widgets/avatar_button.dart';
import 'package:starpath/widgets/search_bar.dart';
import 'package:starpath/widgets/post.dart';
import 'package:starpath/windows/explore_page.dart';
import 'package:starpath/windows/options.dart';
import 'package:starpath/windows/edit_profile_page.dart';
import 'package:supabase/supabase.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late Future<Map<String, dynamic>> _profileFuture;
  late Future<List<PostData>> _postsFuture;
  late Future<List<Map<String, dynamic>>> _avatarFuture;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>().user!;
    _profileFuture = getProfile(user);
    _postsFuture = getPostAsync(user);
    _avatarFuture = getProfilePicture(user);
  }

  void _showEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfilePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil de Usuario'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: _showEditProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            FutureBuilder<Map<String, dynamic>>(
              future: _profileFuture,
              builder: (context, profileSnapshot) {
                if (profileSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (profileSnapshot.hasError) {
                  return Center(child: Text('Error al cargar el perfil'));
                } else {
                  final profileData = profileSnapshot.data ?? {};
                  final imageUrl = profileData['profile_picture'] as String?;
                  final bio = profileData['bio'] as String?;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AvatarButton(
                          profilePictureFuture: _avatarFuture,
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Biografía',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                bio ?? '',
                                style: TextStyle(fontSize: 16),
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
            SizedBox(height: 16),
            FutureBuilder<List<PostData>>(
              future: _postsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text('Error al cargar las publicaciones'));
                } else {
                  final posts = snapshot.data ?? [];
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      return Post(postData: posts[index]);
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> getProfile(User user) async {
    var profile = await supabase
        .from("user")
        .select("id_user, username, bio, profile_picture")
        .eq("id_user", user.id)
        .single();
    return profile;
  }

  Future<List<Map<String, dynamic>>> getProfilePicture(User user) async {
    var profilePicture = await supabase
        .from("user")
        .select("profile_picture")
        .eq("id_user", user.id);
    return profilePicture;
  }

  Future<List<PostData>> getPostAsync(User user) async {
    List<PostData> postList = [];
    PostData post;
    var res = await supabase
        .from('post')
        .select("*")
        .match({'id_user': user.id}).order('created_at', ascending: false);
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
}
