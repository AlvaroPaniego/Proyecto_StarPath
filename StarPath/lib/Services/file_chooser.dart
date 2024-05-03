import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:starpath/misc/constants.dart';
import 'package:supabase/supabase.dart';

class FileChooser{
  static Future<void> uploadContent(User user, String bucket, String table) async{
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.media);
    //Si no es null el usuario ha escogido un archivo y si es null el usuario ha cancelado la seleccion
    if(result != null){
      String file = result.names[0].toString();
      String path = result.paths[0].toString();
      await supabase.storage.from(bucket).upload(file, File(path), fileOptions: const FileOptions(upsert: true));
      var res = supabase.storage.from(bucket).getPublicUrl(file);
      // print(res);
      switch(table){
        case "user":
          await supabase.from(table).update({"profile_picture" : res}).eq("id_user", user.id);
          break;
        case "post":
          await supabase.from(table).update({"content" : res}).eq("id_user", user.id);
          break;
      }
    }else{
      print("No se ha seleccionado nada");
    }
  }
  static Future<String> getContent(User user, String table, String field) async{
    String fileUrl = "";
    await supabase.from(table).select(field).eq('id_user', user.id).then((value) => fileUrl = value.toString());
    print(fileUrl);
    return fileUrl;
  }
}