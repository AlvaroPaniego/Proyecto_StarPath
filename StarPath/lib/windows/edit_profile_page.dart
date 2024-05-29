import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:starpath/misc/constants.dart';
import 'package:starpath/model/user.dart';
import 'package:starpath/model/profile_picture_manager.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  String? _profilePictureUrl;
  bool _isPublic = true;
  final ProfilePictureManager _profilePictureManager = ProfilePictureManager();
  late Future<List<Map<String, dynamic>>> _profilePictureFuture;

  @override
  void initState() {
    super.initState();
    final userProvider = context.read<UserProvider>();
    final user = userProvider.user!;
    _profilePictureFuture = _getProfilePicture(user.id);
  }

  Future<List<Map<String, dynamic>>> _getProfilePicture(String userId) async {
    final response = await supabase
        .from('user')
        .select('username, bio, profile_picture, privacy')
        .eq('id_user', userId)
        .single();

    setState(() {
      _usernameController.text = response['username'];
      _bioController.text = response['bio'] ?? '';
      _profilePictureUrl = response['profile_picture'];
      _isPublic = response['privacy'];
    });

    return [response];
  }

  Future<bool> _checkUsernameAvailability(String username) async {
    final response =
        await supabase.from('user').select('id_user').eq('username', username);

    return response == null;
  }

  Future<void> _saveProfile() async {
    final userProvider = context.read<UserProvider>();
    final user = userProvider.user!;
    final username = _usernameController.text;

    final usernameAvailable = await _checkUsernameAvailability(username);

    if (!usernameAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('El nombre de usuario ya está en uso.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await supabase.from('user').update({
      'username': username,
      'bio': _bioController.text,
      'profile_picture': _profilePictureUrl,
      'privacy': _isPublic,
    }).eq('id', user.id);

    _profilePictureUrl != null
        ? userProvider.updateProfilePictureUrl(_profilePictureUrl!)
        : null;

    Navigator.pop(context);
  }

  Future<void> _changeProfilePicture() async {
    final userProvider = context.read<UserProvider>();
    final user = userProvider.user;

    if (user != null) {
      final newUrl = await _profilePictureManager.uploadContent(
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
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: _changeProfilePicture,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: _profilePictureUrl != null
                          ? NetworkImage(_profilePictureUrl!)
                          : AssetImage('assets/images/placeholder-avatar.jpg')
                              as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Nombre de Usuario'),
              ),
              TextField(
                controller: _bioController,
                decoration: InputDecoration(
                  labelText: 'Biografía',
                  alignLabelWithHint: true,
                  counterText: '${_bioController.text.length}/150',
                ),
                maxLines: null,
                maxLength: 150,
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
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProfile,
                child: Text('Actualizar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
