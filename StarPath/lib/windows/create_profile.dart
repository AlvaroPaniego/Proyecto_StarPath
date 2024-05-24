import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:starpath/misc/constants.dart';
import 'package:starpath/widgets/upper_app_bar.dart';
import 'package:starpath/model/profile_picture_manager.dart';
import 'package:starpath/windows/login.dart';
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
  final ProfilePictureManager _profilePictureManager = ProfilePictureManager();
  late Future<List<Map<String, dynamic>>> _profilePictureFuture;

  @override
  void initState() {
    super.initState();
    _profilePictureFuture = _getProfilePicture();
    _showInfoDialog();
  }

  void _showInfoDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text("Subir foto de perfil"),
        content: Text("¿Desea subir una foto de perfil?"),
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              Navigator.of(context).pop();
              _uploadProfilePicture();
            },
            child: Text("Sí"),
          ),
          CupertinoDialogAction(
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
        String? imageUrl = await _profilePictureManager.uploadContent(
            user, filePath, fileName);
        if (imageUrl != null) {
          setState(() {
            _profilePictureFuture = _getProfilePicture();
          });
        } else {
          print("No se pudo obtener la URL de la imagen del perfil");
        }
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
        final response = await supabase
            .from('user')
            .select('profile_picture')
            .eq('id_user', user.id);
        if (response == null) {
          print('Error al obtener la foto de perfil: ${response}');
          return [];
        }
        List<Map<String, dynamic>> profilePictureData =
            response as List<Map<String, dynamic>>;
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
        await supabase
            .from('user')
            .update({'bio': bio, 'privacy': privacy}).eq('id_user', user.id);
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
          const UpperAppBar(content: [Text("Creación de usuario")]),
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: _showUploadDialog,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Stack(
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
                    const Positioned(
                      bottom: 10.0,
                      right: 10.0,
                      child: Icon(Icons.change_circle_outlined),
                    )
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              decoration: BoxDecoration(
                color: BUTTON_BAR_BACKGROUND,
                borderRadius: BorderRadius.circular(25.0),
              ),
              margin: const EdgeInsets.all(12.0),
              padding:
                  const EdgeInsets.symmetric(vertical: 5.0, horizontal: 12.0),
              child: TextField(
                controller: _textController,
                maxLines: 5,
                style: const TextStyle(color: BLACK, fontSize: 14.0),
                decoration: const InputDecoration.collapsed(
                    hintText: "Escribe tu biografía aquí"),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text(
                  "Perfil público",
                  style: TextStyle(color: TEXT),
                ),
                Checkbox(
                  value: privacy,
                  onChanged: (value) {
                    setState(() {
                      privacy = value ?? false;
                    });
                  },
                )
              ],
            ),
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
                  MaterialPageRoute(builder: (context) => Login()),
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
