import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:starpath/misc/constants.dart';
import 'package:starpath/model/events.dart';
import 'package:starpath/model/user.dart';
import 'package:starpath/model/user_data.dart';
import 'package:starpath/widgets/back_arrow.dart';
import 'package:starpath/widgets/upper_app_bar.dart';
import 'package:starpath/windows/event_main_page.dart';
import 'package:supabase/supabase.dart';

class EditEventPage extends StatefulWidget {
  final EventData eventData;
  const EditEventPage({super.key, required this.eventData});

  @override
  State<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  DateTime? eventDate;
  String fileName = "";
  String filePath = "";
  @override
  void initState() {
    super.initState();
    _titleController.text = widget.eventData.title;
    _dateController.text = widget.eventData.eventDate;
    _descriptionController.text = widget.eventData.description;
    var date = widget.eventData.eventDate.split('/');
    eventDate =
        DateTime(int.parse(date[2]), int.parse(date[0]), int.parse(date[1]));
  }

  @override
  Widget build(BuildContext context) {
    User user = context.watch<UserProvider>().user!;
    bool hasLocalImage = filePath.isNotEmpty;
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
                //   BackArrow(
                //       route: MaterialPageRoute(
                //         builder: (context) => const EventMainPage(),
                //       )),
                //   const Text('Editar evento', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                //   const SizedBox(width: 50,)
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
                              builder: (context) => const EventMainPage(),
                            ),
                          ),
                          const Text('Editar evento', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                          const SizedBox(width: 40,)
                        ],
                      ),
                    )
                ),
                hasLocalImage
                    ? Image.file(File(filePath))
                    : Image.network(widget.eventData.eventImage),
                ElevatedButton(
                    onPressed: () async {
                      FilePickerResult? result = await FilePicker.platform
                          .pickFiles(type: FileType.media);
                      if (result != null) {
                        setState(() {
                          filePath = result.files.single.path!;
                          fileName = result.files.single.name!;
                          hasLocalImage = true;
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
                    controller: _titleController,
                    decoration:
                    const InputDecoration(hintText: "Introduce el título", hintStyle: TextStyle(color: TEXT)),
                    style: const TextStyle(color: TEXT),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    onTapOutside: (event) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      hintText: "Introduce la descripción",
                      hintStyle: const TextStyle(color: TEXT),
                      counterText: '${_descriptionController.text.length}/150',
                      counterStyle: const TextStyle(color: FOCUS_ORANGE),
                    ),
                    maxLines: null,
                    maxLength: 150,
                    style: const TextStyle(color: TEXT),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    onTapOutside: (event) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                    controller: _dateController,
                    decoration: const InputDecoration(
                        labelText: "Introduce la fecha",
                        labelStyle: TextStyle(color: FOCUS_ORANGE),
                        prefixIcon: Icon((Icons.calendar_month), color: TEXT,)),
                    readOnly: true,
                    onTap: () {
                      selectDate();
                    },
                    style: const TextStyle(color: TEXT),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (eventDate == null) {
                      _showErrorDialogDate();
                    } else {
                      _showConfirmationDialog(user);
                    }
                  },
                  style: const ButtonStyle(
                      backgroundColor:
                      MaterialStatePropertyAll(BUTTON_BACKGROUND)),
                  child: const Text(
                    "Modificar",
                    style: TextStyle(color: TEXT),
                  ),
                )
              ],
            ),
          );
        },)
        // Column(
        //   children: [
        //     SizedBox(
        //       height: MediaQuery.of(context).viewPadding.top,
        //     ),
        //     UpperAppBar(content: [
        //       BackArrow(
        //           route: MaterialPageRoute(
        //         builder: (context) => const EventMainPage(),
        //       )),
        //       const Text('Editar evento', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
        //       const SizedBox(width: 50,)
        //     ]),
        //     Expanded(
        //         flex: 4,
        //         child: hasLocalImage
        //             ? Image.file(File(filePath))
        //             : Image.network(widget.eventData.eventImage)),
        //     Flexible(
        //       flex: 1,
        //       child: ElevatedButton(
        //           onPressed: () async {
        //             FilePickerResult? result = await FilePicker.platform
        //                 .pickFiles(type: FileType.media);
        //             if (result != null) {
        //               setState(() {
        //                 filePath = result.files.single.path!;
        //                 fileName = result.files.single.name!;
        //                 hasLocalImage = true;
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
        //       flex: 1,
        //       child: Padding(
        //         padding: const EdgeInsets.all(8.0),
        //         child: TextField(
        //           onTapOutside: (event) =>
        //               FocusManager.instance.primaryFocus?.unfocus(),
        //           controller: _titleController,
        //           decoration:
        //               const InputDecoration(hintText: "Introduce el título", hintStyle: TextStyle(color: TEXT)),
        //           style: const TextStyle(color: TEXT),
        //         ),
        //       ),
        //     ),
        //     Expanded(
        //       flex: 1,
        //       child: Padding(
        //         padding: const EdgeInsets.all(8.0),
        //         child: TextField(
        //           onTapOutside: (event) =>
        //               FocusManager.instance.primaryFocus?.unfocus(),
        //           controller: _descriptionController,
        //           decoration: InputDecoration(
        //               hintText: "Introduce la descripción",
        //               hintStyle: const TextStyle(color: TEXT),
        //               counterText: '${_descriptionController.text.length}/150',
        //               counterStyle: const TextStyle(color: FOCUS_ORANGE),
        //             ),
        //           maxLines: null,
        //           maxLength: 150,
        //           style: const TextStyle(color: TEXT),
        //         ),
        //       ),
        //     ),
        //     Expanded(
        //       flex: 1,
        //       child: Padding(
        //         padding: const EdgeInsets.all(8.0),
        //         child: TextField(
        //           onTapOutside: (event) =>
        //               FocusManager.instance.primaryFocus?.unfocus(),
        //           controller: _dateController,
        //           decoration: const InputDecoration(
        //               labelText: "Introduce la fecha",
        //               labelStyle: TextStyle(color: FOCUS_ORANGE),
        //               prefixIcon: Icon((Icons.calendar_month), color: TEXT,)),
        //           readOnly: true,
        //           onTap: () {
        //             selectDate();
        //           },
        //           style: const TextStyle(color: TEXT),
        //         ),
        //       ),
        //     ),
        //     Flexible(
        //       flex: 1,
        //       child: ElevatedButton(
        //         onPressed: () {
        //           if (eventDate == null) {
        //             _showErrorDialogDate();
        //           } else {
        //             _showConfirmationDialog(user);
        //           }
        //         },
        //         style: const ButtonStyle(
        //             backgroundColor:
        //                 MaterialStatePropertyAll(BUTTON_BACKGROUND)),
        //         child: const Text(
        //           "Modificar",
        //           style: TextStyle(color: TEXT),
        //         ),
        //       ),
        //     )
        //   ],
        // )
    );
  }

  Future<void> _showErrorDialogDate() async {
    return showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Error'),
          content:
              const Text('No se ha seleccionado ninguna fecha para el evento.'),
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

  Future<void> selectDate() async {
    DateFormat format = DateFormat.yMd();
    var selectedDate = await showDatePicker(
        context: context, firstDate: DateTime.now(), lastDate: DateTime(2100));
    if (selectedDate != null) {
      setState(() {
        _dateController.text =
            format.format(DateTime.parse(selectedDate.toString()));
        eventDate = selectedDate;
      });
    }
  }

  Future<void> _showConfirmationDialog(User user) async {
    return showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Confirmación'),
          content:
              const Text('¿Estás seguro de que deseas modificar este evento?'),
          actions: <Widget>[
            CupertinoDialogAction(
              onPressed: () async {
                await updateEvent(
                    widget.eventData.username,
                    filePath,
                    fileName,
                    _titleController.text.trim(),
                    _descriptionController.text.trim(),
                    eventDate,
                    widget.eventData.idEvent);
                Navigator.of(context).pop();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const EventMainPage()));
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

  Future<void> updateEvent(String username, String path, String fileName,
      String title, String description, DateTime? time, String idEvent) async {
    String res;
    if (path.isEmpty) {
      res = widget.eventData.eventImage;
    } else {
      await supabase.storage.from("publicacion").upload(fileName, File(path),
          fileOptions: const FileOptions(upsert: true));
      res = supabase.storage.from("publicacion").getPublicUrl(fileName);
    }

    await supabase.from("events").update({
      'time': time.toString(),
      'title': title,
      'description': description,
      'name_user': username,
      'event_image': res
    }).eq('id', idEvent);
  }
  // Future<UserData> getUserDataAsync(String id_user) async{
  //   UserData user = UserData.empty();
  //   var res = await supabase
  //       .from('user')
  //       .select("id_user, username, profile_picture")
  //       .match({'id_user': id_user});
  //   user.id_user = res.first['id_user'];
  //   user.username = res.first['username'];
  //   user.profile_picture = res.first['profile_picture'];
  //   user.followers = '0';
  //   return user;
  // }
}
