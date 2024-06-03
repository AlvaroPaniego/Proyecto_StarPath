import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:starpath/misc/constants.dart';
import 'package:starpath/widgets/upper_app_bar.dart';
import 'package:starpath/model/profile_picture_manager.dart';
import 'package:starpath/windows/login.dart';
import 'package:starpath/windows/main_page.dart';
import 'package:supabase/supabase.dart';
import 'package:starpath/model/user.dart';

class NewProfilePage extends StatefulWidget {
  const NewProfilePage({Key? key}) : super(key: key);

  @override
  State<NewProfilePage> createState() => _NewProfilePageState();
}

class _NewProfilePageState extends State<NewProfilePage> {
  final TextEditingController _textController = TextEditingController();
  bool privacy = false;
  String? profilePictureUrl;
  final ProfilePictureManager _profilePictureManager = ProfilePictureManager();
  late Future<List<Map<String, dynamic>>> _profilePictureFuture;

  @override
  void initState() {
    super.initState();
    _profilePictureFuture = _getProfilePicture();
    _showInfoDialog();
    _textController.addListener(() {
      setState(() {});
    });
  }

  void _showInfoDialog() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text("Información"),
          content: Text(
              "Aquí puede insertar una biografía, una foto de perfil y ajustar la privacidad del perfil."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Aceptar"),
            ),
          ],
        ),
      );
    });
  }

  void _showUploadDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text("Subir foto de perfil"),
        content: Text("¿Desea subir una foto de perfil?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _uploadProfilePicture();
            },
            child: Text("Sí"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("No"),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadProfilePicture() async {
    try {
      User? user = Provider.of<UserProvider>(context, listen: false).user;
      if (user != null) {
        String filePath = "";
        String fileName = "";
        await _profilePictureManager.uploadContent(user, filePath, fileName);
        setState(() {
          _profilePictureFuture = _getProfilePicture();
        });
      } else {
        print("No se pudo obtener el usuario actual");
      }
    } catch (error) {
      print("Error al subir la foto de perfil: $error");
    }
  }

  Future<List<Map<String, dynamic>>> _getProfilePicture() async {
    try {
      User? user = Provider.of<UserProvider>(context, listen: false).user;
      if (user != null) {
        final response = await _profilePictureManager.getContent(
            user, 'user', 'profile_picture');
        if (response == null) {
          print('Error al obtener la foto de perfil');
          return [];
        }
        List<Map<String, dynamic>> profilePictureData =
            response as List<Map<String, dynamic>>;
        if (profilePictureData.isNotEmpty) {
          profilePictureUrl = profilePictureData[0]['profile_picture'];
        }
        return profilePictureData;
      } else {
        print('No se pudo obtener el usuario actual');
        return [];
      }
    } catch (error) {
      print('Error al obtener la foto de perfil: $error');
      return [];
    }
  }

  Future<void> _updateUserProfile() async {
    try {
      User? user = Provider.of<UserProvider>(context, listen: false).user;
      if (user != null) {
        final bio = _textController.text;
        await supabase.from('user').update({
          'bio': bio,
          'privacy': privacy,
          'profile_picture': profilePictureUrl,
        }).eq('id_user', user.id);
        print('Perfil actualizado con éxito');
      } else {
        print('No se pudo obtener el usuario actual');
      }
    } catch (error) {
      print('Error al actualizar el perfil del usuario: $error');
    }
  }

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
              Center(
                child: Text(
                  "Creación de usuario",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: _showUploadDialog,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(180)),
                      child: FutureBuilder(
                        future: _profilePictureFuture,
                        builder: (context,
                            AsyncSnapshot<List<Map<String, dynamic>>>
                                snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Image.asset(
                                "assets/images/placeholder-avatar.jpg");
                          } else if (snapshot.hasError) {
                            return Image.asset(
                                "assets/images/placeholder-avatar.jpg");
                          } else {
                            if (snapshot.data != null &&
                                snapshot.data!.isNotEmpty) {
                              final profilePictureUrl =
                                  snapshot.data![0]["profile_picture"];
                              if (profilePictureUrl != null &&
                                  profilePictureUrl.isNotEmpty) {
                                return Image.network(profilePictureUrl);
                              }
                            }
                            return Image.asset(
                                "assets/images/placeholder-avatar.jpg");
                          }
                        },
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.5),
                      ),
                      padding: EdgeInsets.all(8.0),
                      child: IconButton(
                        iconSize: 48.0,
                        icon: Icon(Icons.add_a_photo, color: Colors.white),
                        onPressed: _showUploadDialog,
                        tooltip: 'Cambiar foto de perfil',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: BUTTON_BAR_BACKGROUND,
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  margin: const EdgeInsets.all(12.0),
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 12.0),
                  child: TextField(
                    controller: _textController,
                    maxLines: 5,
                    maxLength: 150,
                    style: const TextStyle(color: BLACK, fontSize: 14.0),
                    decoration: const InputDecoration(
                      hintText: "Escribe tu biografía aquí",
                      border: InputBorder.none,
                      counterText: '',
                    ),
                  ),
                ),
                Positioned(
                  bottom: 15,
                  right: 20,
                  child: Text(
                    '${_textController.text.length}/150',
                    style: const TextStyle(color: BLACK),
                  ),
                ),
              ],
            ),
          ),
          SwitchListTile(
            title: const Text(
              "Perfil público",
              style: TextStyle(color: TEXT),
            ),
            value: privacy,
            onChanged: (value) {
              setState(() {
                privacy = value;
              });
            },
            activeColor: Colors.blue,
          ),
          Expanded(
            flex: 1,
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(BUTTON_BACKGROUND),
              ),
              onPressed: () async {
                await _updateUserProfile();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MainPage()),
                );
              },
              child: const Text("Finalizar", style: TextStyle(color: TEXT)),
            ),
          )
        ],
      ),
    );
  }
}
