
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:gotrue/src/types/user.dart';
import 'package:starpath/Services/file_chooser.dart';
import 'package:starpath/misc/constants.dart';
import 'package:supabase/supabase.dart';

class ContentManager implements FileChooser{
  @override
  Future<PostgrestList> getContent(User user, String table, String field) async{
    PostgrestList profilePicture;
    profilePicture = await supabase
        .from("post")
        .select("content")
        .eq("id_user", user.id);
    // print(profilePicture);
    return profilePicture;
  }

  @override
  Future<void> uploadContent(User user) async {
    {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.media);
      //Si no es null el usuario ha escogido un archivo y si es null el usuario ha cancelado la seleccion
      if(result != null){
        String file = result.names[0].toString();
        String path = result.paths[0].toString();
        await supabase.storage.from("pruebas").upload(file, File(path), fileOptions: const FileOptions(upsert: true));
        var res = supabase.storage.from("pruebas").getPublicUrl(file);
        // print(res);
        await supabase.from("post").update({"content" : res}).eq("id_user", user.id);
      }else{
        print("No se ha seleccionado nada");
      }
    }
  }

}