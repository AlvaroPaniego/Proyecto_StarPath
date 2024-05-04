import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:starpath/misc/constants.dart';
import 'package:starpath/model/user.dart';
import 'package:starpath/widgets/back_arrow.dart';
import 'package:starpath/widgets/upper_app_bar.dart';
import 'package:supabase/supabase.dart';

class ContentUploadPage extends StatefulWidget {
  const ContentUploadPage({super.key});

  @override
  State<ContentUploadPage> createState() => _ContentUploadPageState();
}

class _ContentUploadPageState extends State<ContentUploadPage> {
  final TextEditingController _textController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    User user = context.watch<UserProvider>().user!;
    String selectedImagePath = "";
    Future<String> selectedImageFuture = Future.error(Exception);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: BACKGROUND,
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).viewPadding.top,
          ),
          const UpperAppBar(content: [
            BackArrow()
            ]
          ),
          // imagePreview(selectedImagePath),
          Expanded(
            flex: 8,
            child: FutureBuilder(future: selectedImageFuture, builder: (context, snapshot) {
              if(snapshot.hasError){
                print("error: ${snapshot.error}");
                return const Center(child: Text("Ninguna imagen seleccionada para subir",
                  style: TextStyle(color: TEXT),));
              }else if(snapshot.hasData){
                print("path: ${snapshot.data}");
                return Center(child: Image.file(File(snapshot.data!)));
              }
              return const Center(child: Text("Ninguna imagen seleccionada para subir",
                style: TextStyle(color: TEXT),));
            },),
          ),
          Expanded(
            flex: 1,
            child: ElevatedButton(
                onPressed: () async{
                  FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.media);
                  setState(() {
                    selectedImageFuture = getPreviewImage(result!);
                    selectedImageFuture.then((value) => print("contenido future: $value"));
                  });
                },
                style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(BUTTON_BACKGROUND)),
                child: const Text("Seleccionar foto", style: TextStyle(color: TEXT))),
          ),
          Expanded(flex: 1, child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(controller: _textController, decoration: const InputDecoration(hintText: "Introduce la descripcion")),
          )),
          Expanded(
            flex: 1,
            child: ElevatedButton(
                onPressed: () {
                  setState(() {


                  });
                },
                style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(BUTTON_BACKGROUND)),
                child: const Text("Subir imagen", style: TextStyle(color: TEXT))),
          )
        ],
      ),
    );
  }

  imagePreview(String selectedImagePath) {
    if (selectedImagePath == "") {
      return const Expanded(
          flex: 8,
          child: Center(child: Text("Ninguna imagen seleccionada para subir",
            style: TextStyle(color: TEXT),)));
    } else {
      return Expanded(
          flex: 8,
          child: Image.file(File(selectedImagePath)));
    }
  }
  Future<String> getPreviewImage(FilePickerResult result) async {
    String path = "";
    path = result!.files[0].path!;
    return path;
  }
}

