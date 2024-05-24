import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:starpath/model/user.dart';
import 'package:starpath/model/profile_picture_manager.dart';
import 'package:starpath/misc/constants.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  String? _profilePictureUrl;
  bool _isPublic = true;

  @override
  void initState() {
    super.initState();
    final userProvider = context.read<UserProvider>();
    final user = userProvider.user!;
    _fetchUserProfile(user.id);
  }

  Future<void> _fetchUserProfile(String userId) async {
    final response =
        await supabase.from('user').select('*').eq('id', userId).single();

    setState(() {
      _usernameController.text = response['username'];
      _bioController.text = response['bio'] ?? '';
      _profilePictureUrl = response['profile_picture'];
      _isPublic = response['is_public'];
    });
  }

  Future<void> _saveProfile() async {
    final userProvider = context.read<UserProvider>();
    final user = userProvider.user!;
    await supabase.from('user').update({
      'username': _usernameController.text,
      'bio': _bioController.text,
      'profile_picture': _profilePictureUrl,
      'is_public': _isPublic,
    }).eq('id', user.id);

    _profilePictureUrl != null
        ? userProvider.updateProfilePictureUrl(_profilePictureUrl!)
        : null;

    Navigator.pop(context);
  }

  Future<void> _changeProfilePicture() async {
    final profilePictureManager = ProfilePictureManager();
    final userProvider = context.read<UserProvider>();
    final user = userProvider.user;

    if (user != null) {
      final newUrl = await profilePictureManager.uploadContent(
        user,
        "",
        "",
      );
      if (newUrl != null) {
        setState(() {
          _profilePictureUrl = newUrl;
        });
        userProvider.updateProfilePictureUrl(newUrl);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Perfil'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _changeProfilePicture,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(
                    _profilePictureUrl ?? 'https://via.placeholder.com/150'),
              ),
            ),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Nombre de Usuario'),
            ),
            TextField(
              controller: _bioController,
              decoration: InputDecoration(labelText: 'Biografía'),
            ),
            SwitchListTile(
              title: Text('Perfil Público'),
              value: _isPublic,
              onChanged: (value) {
                setState(() {
                  _isPublic = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
