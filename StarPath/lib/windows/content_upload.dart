import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:starpath/misc/constants.dart';
import 'package:starpath/model/content_managet.dart';
import 'package:starpath/model/user.dart';
import 'package:starpath/widgets/back_arrow.dart';
import 'package:starpath/widgets/upper_app_bar.dart';
import 'package:starpath/windows/main_page.dart';
import 'package:supabase/supabase.dart';

class ContentUploadPage extends StatefulWidget {
  const ContentUploadPage({super.key});

  @override
  State<ContentUploadPage> createState() => _ContentUploadPageState();
}

class _ContentUploadPageState extends State<ContentUploadPage> {
  final TextEditingController _textController = TextEditingController();
  String fileName = "";
  String filePath ="";
  @override
  Widget build(BuildContext context) {
    User user = context.watch<UserProvider>().user!;
    List<String> selectedImageFuture = [];
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
              flex: 4,
              child: Text(fileName)),
          Expanded(
              flex: 4,
              child: Text(filePath)),
          Expanded(
            flex: 1,
            child: ElevatedButton(
                onPressed: () async{
                  FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.media);
                  selectedImageFuture = await getPreviewImage(result!);
                  setState(() {
                    filePath = selectedImageFuture[0];
                    fileName = selectedImageFuture[1];
                  });
                },
                style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(BUTTON_BACKGROUND)),
                child: const Text("Seleccionar foto", style: TextStyle(color: TEXT))),
          ),
          Expanded(flex: 1, child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(controller: _textController,
                decoration: const InputDecoration(hintText: "Introduce la descripcion"),
                style: const TextStyle(color: TEXT),
            ),
          )),
          Expanded(
            flex: 1,
            child: ElevatedButton(
                onPressed: () async{
                  if(fileName.isNotEmpty && filePath.isNotEmpty){
                    await uploadContent(user, filePath, fileName, _textController.text.trim());
                    print("Todo correcto");
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const MainPage()));
                  }else{
                    print("faltan datos");
                  }
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
  Future<List<String>> getPreviewImage(FilePickerResult result) async {
    List<String> info = ["", ""];
    info[0] = result.files[0].path!;
    info[1] = result.files[0].name;
    return info;
  }
  Future<void> uploadContent(User user, String path, String fileName, String description) async {
    {
        await supabase.storage.from("publicacion").upload(fileName, File(path), fileOptions: const FileOptions(upsert: true));
        var res = supabase.storage.from("publicacion").getPublicUrl(fileName);
        // print(res);
        await supabase.from("post").insert({
          'id_user' : user.id,
          'description' : description,
          'content' : res
        });
    }
  }
}

