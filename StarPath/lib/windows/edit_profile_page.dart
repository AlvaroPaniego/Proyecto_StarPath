import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';
import 'package:starpath/misc/constants.dart';
import 'package:starpath/model/user.dart';
import 'package:starpath/model/user_data.dart';
import 'package:starpath/model/profile_picture_manager.dart';
import 'package:starpath/widgets/back_arrow.dart';
import 'package:starpath/widgets/upper_app_bar.dart';
import 'package:starpath/windows/main_page.dart';
import 'package:starpath/windows/user_profile_page.dart';
import 'package:starpath/windows/login.dart';
import 'package:supabase/supabase.dart';

class EditProfilePage extends StatefulWidget {
  final UserData userData;

  EditProfilePage({required this.userData});
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  String? _profilePictureUrl;
  bool _isPublic = true;
  final ProfilePictureManager _profilePictureManager = ProfilePictureManager();
  late Future<void> _profilePictureFuture;

  @override
  void initState() {
    super.initState();
    _profilePictureFuture = _initializeUserProfile();
  }

  Future<void> _initializeUserProfile() async {
    final userProvider = context.read<UserProvider>();
    final user = userProvider.user!;
    await _getUserProfile(user.id);
  }

  Future<void> _getUserProfile(String userId) async {
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
  }

  Future<bool> _checkUsernameAvailability(String username) async {
    final response =
        await supabase.from('user').select('id_user').eq('username', username);
    return response.isEmpty ||
        (response.length == 1 &&
            response[0]['id_user'] == context.read<UserProvider>().user!.id);
  }

  Future<void> _saveProfile() async {
    final userProvider = context.read<UserProvider>();
    final user = userProvider.user!;
    final username = _usernameController.text;

    final usernameAvailable = await _checkUsernameAvailability(username);

    if (!usernameAvailable) {
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text('Error'),
            content: Text('El nombre de usuario ya está en uso.'),
            actions: [
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Aceptar'),
              ),
            ],
          );
        },
      );

      return;
    }

    await supabase.from('user').update({
      'username': username,
      'bio': _bioController.text,
      'profile_picture': _profilePictureUrl,
      'privacy': _isPublic,
    }).eq('id_user', user.id);

    if (_profilePictureUrl != null) {
      userProvider.updateProfilePictureUrl(_profilePictureUrl!);
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfilePage(userData: widget.userData),
      ),
    );
  }

  Future<void> _changeProfilePicture() async {
    // final pickedFile =
    //     await ImagePicker().pickImage(source: ImageSource.gallery);

    /*if (pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9,
        ],
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Recortar imagen',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
        ],
      );

    } */

    // if (pickedFile != null) {
    final userProvider = context.read<UserProvider>();
    final user = userProvider.user!;

    final newUrl = await _profilePictureManager.uploadContent(user, '', "");

    if (newUrl != null) {
      setState(() {
        _profilePictureUrl = newUrl;
      });
      userProvider.updateProfilePictureUrl(newUrl);
    }
  }

  void _changeEmail(BuildContext context) {
    String newEmail = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Cambiar Correo Electrónico'),
          content: CupertinoTextField(
            placeholder: 'Introduce la nueva dirección de email',
            onChanged: (value) => newEmail = value,
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('Cancelar'),
              onPressed: () => Navigator.pop(context),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: Text('Guardar'),
              onPressed: () async {
                if (!_isValidEmail(newEmail)) {
                  Navigator.pop(context);
                  showCupertinoDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CupertinoAlertDialog(
                        title: Text('Error'),
                        content: Text('El correo electrónico no es válido.'),
                        actions: [
                          CupertinoDialogAction(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Aceptar'),
                          ),
                        ],
                      );
                    },
                  );
                  return;
                }

                final userProvider = context.read<UserProvider>();
                final user = userProvider.user;
                if (user != null && user.email != null) {
                  try {
                    final UserResponse res = await supabase.auth.updateUser(
                      UserAttributes(email: newEmail),
                    );
                    final User? updatedUser = res.user;
                    if (updatedUser != null) {
                      print('Correo electrónico actualizado correctamente');
                      Navigator.pop(context);
                      showCupertinoDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CupertinoAlertDialog(
                            title: Text('Correo Enviado'),
                            content: Text(
                                'Se ha enviado un correo electrónico a $newEmail. Serás redirigido a la ventana de login.'),
                            actions: [
                              CupertinoDialogAction(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Login()),
                                  );
                                },
                                child: Text('Aceptar'),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      print('Error al actualizar el usuario');
                    }
                  } catch (error) {
                    print('Error inesperado: $error');
                  }
                } else {
                  print('Usuario no autenticado o falta información de email');
                }
              },
            ),
          ],
        );
      },
    );
  }

  bool _isValidEmail(String email) {
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  void _deleteUser(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar Usuario'),
          content: Text(
              '¿Estás seguro de que deseas eliminar tu cuenta? Esta acción no se puede deshacer.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar el cuadro de diálogo
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  final userProvider = context.read<UserProvider>();
                  final user = userProvider.user!;

                  await supabase.from('user').delete().eq('id_user', user.id);
                  await supabase.auth.signOut();

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Login(),
                    ),
                  );
                } catch (error) {
                  print('Error al eliminar la cuenta: $error');
                }
              },
              child: Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BACKGROUND,
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).viewPadding.top,
          ),
          UpperAppBar(content: [
            BackArrow(
                route: MaterialPageRoute(
              builder: (context) => const MainPage(),
            )),
            const Text(
              'Editar usuario',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              width: 50,
            ),
          ]),
          Expanded(
            flex: 9,
            child: FutureBuilder(
              future: _profilePictureFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                return SingleChildScrollView(
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
                                    : const AssetImage(
                                            'assets/images/placeholder-avatar.jpg')
                                        as ImageProvider,
                                fit: BoxFit.cover,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  spreadRadius: 2,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),
                        ),
                        TextField(
                          onTapOutside: (event) =>
                              FocusManager.instance.primaryFocus?.unfocus(),
                          controller: _usernameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelStyle: TextStyle(color: FOCUS_ORANGE),
                            labelText: 'Nombre de Usuario',
                          ),
                        ),
                        TextField(
                          controller: _bioController,
                          style: const TextStyle(color: Colors.white),
                          onTapOutside: (event) =>
                              FocusManager.instance.primaryFocus?.unfocus(),
                          decoration: InputDecoration(
                            labelText: 'Biografía',
                            alignLabelWithHint: true,
                            labelStyle: const TextStyle(color: FOCUS_ORANGE),
                            counterText: '${_bioController.text.length}/150',
                            counterStyle: const TextStyle(color: FOCUS_ORANGE),
                          ),
                          maxLines: null,
                          maxLength: 150,
                        ),
                        SwitchListTile(
                          title: const Text('Perfil Público',
                              style: TextStyle(color: Colors.white)),
                          value: _isPublic,
                          onChanged: (value) {
                            setState(() {
                              _isPublic = value;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _saveProfile,
                          child: const Text('Actualizar'),
                        ),
                        // ElevatedButton(
                        //   onPressed: () => _changeEmail(context),
                        //   child: const Text('Cambiar Correo Electrónico'),
                        // ),
                        const SizedBox(height: 50),
                        ElevatedButton(
                          onPressed: () => _deleteUser(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red
                            //primary: Colors.red,
                          ),
                          child: const Text('Eliminar Cuenta',style: TextStyle(color: BLACK),),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
