import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:starpath/misc/constants.dart';
import 'package:starpath/model/user.dart';
import 'package:starpath/model/user_data.dart';
import 'package:starpath/widgets/back_arrow.dart';
import 'package:starpath/widgets/upper_app_bar.dart';
import 'package:starpath/windows/event_main_page.dart';
import 'package:supabase/supabase.dart';
import 'package:geolocator/geolocator.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({Key? key}) : super(key: key);

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  String fileName = "";
  String filePath = "";
  bool isImageSelected = false;
  DateTime? eventDate;
  Position? userPosition;

  @override
  Widget build(BuildContext context) {
    User user = context.watch<UserProvider>().user!;
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      backgroundColor: BACKGROUND,
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).viewPadding.top,
          ),
          UpperAppBar(content: [
            BackArrow(
              route: MaterialPageRoute(
                builder: (context) => const EventMainPage(),
              ),
            ),
          ]),
          Expanded(
            flex: 6,
            child: isImageSelected
                ? Image.file(File(filePath))
                : const Center(
                    child: Text(
                      "Ninguna imagen seleccionada para subir",
                      style: TextStyle(color: TEXT),
                    ),
                  ),
          ),
          Flexible(
            flex: 1,
            child: ElevatedButton(
                onPressed: () async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles(type: FileType.media);
                  if (result != null) {
                    setState(() {
                      filePath = result.files.single.path!;
                      fileName = result.files.single.name!;
                      isImageSelected = true;
                    });
                  }
                },
                style: const ButtonStyle(
                    backgroundColor:
                        MaterialStatePropertyAll(BUTTON_BACKGROUND)),
                child: const Text("Seleccionar foto",
                    style: TextStyle(color: TEXT))),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onTapOutside: (event) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                controller: _titleController,
                decoration:
                    const InputDecoration(
                      hintText: "Introduce el título",
                      hintStyle: TextStyle(color: TEXT),
                    ),
                style: const TextStyle(color: TEXT),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onTapOutside: (event) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                controller: _descriptionController,
                decoration:
                    InputDecoration(hintText: "Introduce la descripción",
                        hintStyle: const TextStyle(color: TEXT),
                        counterText: '${_descriptionController.text.length}/150',
                        counterStyle: const TextStyle(color: FOCUS_ORANGE),
                    ),
                maxLines: null,
                maxLength: 150,
                style: const TextStyle(color: TEXT),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
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
          ),
          Flexible(
            flex: 1,
            child: ElevatedButton(
              onPressed: () {
                if (!isImageSelected) {
                  _showErrorDialog();
                } else if (eventDate == null) {
                  _showErrorDialogDate();
                } else {
                  _onCreateEventButtonPressed(user);
                }
              },
              style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(BUTTON_BACKGROUND)),
              child: const Text(
                "Crear evento",
                style: TextStyle(color: TEXT),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _onCreateEventButtonPressed(User user) {
    _getUserPositionAndShowConfirmationDialog(user);
  }

  Future<void> _getUserPositionAndShowConfirmationDialog(User user) async {
    try {
      userPosition = await Geolocator.getCurrentPosition();
      _showConfirmationDialogIfNeeded(user);
    } catch (e) {
      _showErrorDialog2('Error al obtener la posición del usuario: $e');
    }
  }

  void _showConfirmationDialogIfNeeded(User user) {
    if (userPosition != null) {
      _showConfirmationDialog(user);
    } else {
      _showErrorDialog2('No se proporcionó la posición del usuario');
    }
  }

  Future<void> _showConfirmationDialog(User user) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmación'),
          content: const Text('¿Estás seguro de que deseas crear este evento?'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                try {
                  await uploadContent(
                    user,
                    filePath,
                    fileName,
                    _titleController.text.trim(),
                    _descriptionController.text.trim(),
                    eventDate,
                  );
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EventMainPage(),
                    ),
                  );
                } catch (e) {
                  _showErrorDialog2('Error al crear el evento: $e');
                }
              },
              child: const Text('Aceptar'),
            ),
            TextButton(
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

  Future<void> uploadContent(User user, String path, String fileName,
      String title, String description, DateTime? time) async {
    await supabase.storage.from("publicacion").upload(fileName, File(path),
        fileOptions: const FileOptions(upsert: true));
    var res = supabase.storage.from("publicacion").getPublicUrl(fileName);
    var userData = await getUserDataAsync(user.id);

    // Insertar los datos del evento en la tabla events
    final eventDataResponse = await supabase.from("events").insert({
      'name_user': userData.username,
      'title': title,
      'description': description,
      'event_image': res,
      'time': time.toString()
    }).select();

    if (eventDataResponse == null) {
      throw Exception('Error al insertar el evento');
    }

    print('La inserción del evento fue exitosa y no hay errores');
    int eventId = eventDataResponse[0]['id'];
    // Obtener el ID del evento creado
    print('El id del evento creado es $eventId');

    // Insertar la ubicación del evento en la tabla event_location
    final locationInsertionResponse =
        await supabase.from("event_location").insert({
      'id': eventId,
      'latitude': userPosition!.latitude,
      'longitude': userPosition!.longitude,
    });

    if (locationInsertionResponse != null &&
        locationInsertionResponse.error != null) {
      throw Exception(
          'Error al insertar la ubicación del evento: ${locationInsertionResponse.error!.message}');
    }

    // Insertar el evento y el usuario en la tabla event_followers
    final followersInsertionResponse =
        await supabase.from("event_followers").insert({
      'id_event': eventId,
      'id_user': user.id,
    });

    if (followersInsertionResponse != null &&
        followersInsertionResponse.error != null) {
      throw Exception(
          'Error al insertar el seguidor del evento: ${followersInsertionResponse.error!.message}');
    }

    // Si todo guay navegar a la página de Mis Eventos
    Navigator.pop(context);
  }

  Future<void> _showErrorDialog2(String errorMessage) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
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

  Future<void> _showErrorDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: const Text('No se ha seleccionado ninguna foto.'),
          actions: <Widget>[
            TextButton(
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

  Future<void> _showErrorDialogDate() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content:
              const Text('No se ha seleccionado ninguna fecha para el evento.'),
          actions: <Widget>[
            TextButton(
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
  Future<void> selectDate() async{
    DateFormat format = DateFormat.yMd();
    var selectedDate = await showDatePicker(
        context: context,
        firstDate: DateTime.now(),
        lastDate: DateTime(2100)
    );
    if(selectedDate != null){
      setState(() {
        _dateController.text = format.format(DateTime.parse(selectedDate.toString()));
        eventDate = selectedDate;
      });
    }
  }
  Future<UserData> getUserDataAsync(String id_user) async{
    UserData user = UserData.empty();
    var res = await supabase
        .from('user')
        .select("id_user, username, profile_picture")
        .match({'id_user': id_user});
    user.id_user = res.first['id_user'];
    user.username = res.first['username'];
    user.profile_picture = res.first['profile_picture'];
    user.followers = '0';
    return user;
  }
}
