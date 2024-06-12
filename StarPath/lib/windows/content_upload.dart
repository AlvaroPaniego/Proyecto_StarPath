import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:provider/provider.dart';
import 'package:starpath/misc/constants.dart';
import 'package:starpath/model/user.dart';
import 'package:starpath/widgets/back_arrow.dart';
import 'package:starpath/widgets/upper_app_bar.dart';
import 'package:starpath/windows/main_page.dart';
import 'package:supabase/supabase.dart';
import 'package:flutter/cupertino.dart';

class ContentUploadPage extends StatefulWidget {
  const ContentUploadPage({super.key});

  @override
  State<ContentUploadPage> createState() => _ContentUploadPageState();
}

class _ContentUploadPageState extends State<ContentUploadPage> {
  final TextEditingController _textController = TextEditingController();
  String fileName = "";
  String filePath = "";
  bool isImageSelected = false;

  @override
  Widget build(BuildContext context) {
    User user = context.watch<UserProvider>().user!;

    return Scaffold(
      // resizeToAvoidBottomInset: false,
      backgroundColor: BACKGROUND,
      body: KeyboardVisibilityBuilder(builder: (p0, isKeyboardVisible) {
        return SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).viewPadding.top,
              ),
              // UpperAppBar(content: [
              //   BackArrow(route: MaterialPageRoute(builder: (context) => const MainPage(),),),
              // ]),
              Container(
                  decoration: const BoxDecoration(
                      color: BUTTON_BAR_BACKGROUND,
                      borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(30.0))),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        BackArrow(
                          route: MaterialPageRoute(
                            builder: (context) => const MainPage(),
                          ),
                        ),
                        const Text('Subir publicación', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                        const SizedBox(width: 40,)
                      ],
                    ),
                  )
              ),
              isImageSelected
                  ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.file(File(filePath)),
                  )
                  : SizedBox(
                    height: MediaQuery.of(context).size.height*0.4,
                    child: const Center(
                                    child: Text(
                    "Ninguna imagen seleccionada para subir",
                    style: TextStyle(color: TEXT),
                                    ),
                                  ),
                  ),
              ElevatedButton(
                  onPressed: () async {
                    FilePickerResult? result =
                    await FilePicker.platform.pickFiles(type: FileType.media);
                    if (result != null) {
                      setState(() {
                        filePath = result.files.single.path!; //nunca será nulo
                        fileName = result.files.single.name!; //nunca será nulo
                        isImageSelected = true;
                      });
                    }
                  },
                  style: const ButtonStyle(
                      backgroundColor:
                      MaterialStatePropertyAll(BUTTON_BACKGROUND)),
                  child: const Text("Seleccionar foto",
                      style: TextStyle(color: TEXT))),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onTapOutside: (event) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  controller: _textController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelStyle: const TextStyle(color: FOCUS_ORANGE),
                    labelText: 'Introduce la descripción para la publicación',
                    counterStyle: const TextStyle(color: FOCUS_ORANGE),
                  ),
                  maxLines: null,
                  maxLength: 150,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (!isImageSelected) {
                    _showErrorDialog();
                  } else {
                    _showConfirmationDialog(user);
                  }
                },
                style: const ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(BUTTON_BACKGROUND)),
                child: const Text(
                  "Subir imagen",
                  style: TextStyle(color: TEXT),
                ),
              )
            ],
          )
        );
      },)
      // Column(
      //   children: [
      //     SizedBox(
      //       height: MediaQuery.of(context).viewPadding.top,
      //     ),
      //     UpperAppBar(content: [
      //       BackArrow(route: MaterialPageRoute(builder: (context) => const MainPage(),),),
      //     ]),
      //     Expanded(
      //       flex: 6,
      //       child: isImageSelected
      //           ? Image.file(File(filePath))
      //           : const Center(
      //               child: Text(
      //                 "Ninguna imagen seleccionada para subir",
      //                 style: TextStyle(color: TEXT),
      //               ),
      //             ),
      //     ),
      //     Flexible(
      //       flex: 1,
      //       child: ElevatedButton(
      //           onPressed: () async {
      //             FilePickerResult? result =
      //                 await FilePicker.platform.pickFiles(type: FileType.media);
      //             if (result != null) {
      //               setState(() {
      //                 filePath = result.files.single.path!; //nunca será nulo
      //                 fileName = result.files.single.name!; //nunca será nulo
      //                 isImageSelected = true;
      //               });
      //             }
      //           },
      //           style: const ButtonStyle(
      //               backgroundColor:
      //                   MaterialStatePropertyAll(BUTTON_BACKGROUND)),
      //           child: const Text("Seleccionar foto",
      //               style: TextStyle(color: TEXT))),
      //     ),
      //     Expanded(
      //       flex: 2,
      //       child: Padding(
      //         padding: const EdgeInsets.all(8.0),
      //         child: TextField(
      //           onTapOutside: (event) =>
      //               FocusManager.instance.primaryFocus?.unfocus(),
      //           controller: _textController,
      //           style: const TextStyle(color: Colors.white),
      //           decoration: InputDecoration(
      //             labelStyle: const TextStyle(color: FOCUS_ORANGE),
      //             labelText: 'Introduce la descripcion para la publicacion',
      //             counterText: '${_textController.text.length}/150',
      //             counterStyle: const TextStyle(color: FOCUS_ORANGE),
      //           ),
      //           maxLines: null,
      //           maxLength: 150,
      //         ),
      //       ),
      //     ),
      //     Flexible(
      //       flex: 1,
      //       child: ElevatedButton(
      //         onPressed: () {
      //           if (!isImageSelected) {
      //             _showErrorDialog();
      //           } else {
      //             _showConfirmationDialog(user);
      //           }
      //         },
      //         style: const ButtonStyle(
      //             backgroundColor: MaterialStatePropertyAll(BUTTON_BACKGROUND)),
      //         child: const Text(
      //           "Subir imagen",
      //           style: TextStyle(color: TEXT),
      //         ),
      //       ),
      //     )
      //   ],
      // ),
    );
  }

  Future<void> _showConfirmationDialog(User user) async {
    return showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Confirmación'),
          content:
              const Text('¿Estás seguro de que deseas subir esta publicación?'),
          actions: <Widget>[
            CupertinoDialogAction(
              onPressed: () async {
                await uploadContent(
                    user, filePath, fileName, _textController.text.trim());
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MainPage()),
                );
              },
              child: const Text('Aceptar'),
            ),
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> uploadContent(
      User user, String path, String fileName, String description) async {
    await supabase.storage.from("publicacion").upload(fileName, File(path),
        fileOptions: const FileOptions(upsert: true));
    var res = supabase.storage.from("publicacion").getPublicUrl(fileName);
    // print(res);
    await supabase.from("post").insert({
      'id_user': user.id,
      'description': description,
      'content': res,
    });
  }

  Future<void> _showErrorDialog() async {
    return showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Error'),
          content: const Text('No se ha seleccionado ninguna foto.'),
          actions: <Widget>[
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
