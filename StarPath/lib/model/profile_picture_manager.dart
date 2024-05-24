import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:starpath/Services/file_chooser.dart';
import 'package:starpath/misc/constants.dart';
import 'package:supabase/supabase.dart';

class ProfilePictureManager implements FileChooser {
  @override
  Future<String?> uploadContent(
      User user, String filePath, String fileName) async {
    try {
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(type: FileType.media);
      if (result != null) {
        String file = result.names[0].toString();
        String path = result.paths[0].toString();
        await supabase.storage.from("pruebas").upload(file, File(path),
            fileOptions: const FileOptions(upsert: true));
        var res = await supabase.storage.from("pruebas").getPublicUrl(file);

        String? imageUrl = res;
        if (imageUrl != null) {
          await supabase
              .from("user")
              .update({"profile_picture": imageUrl}).eq("id_user", user.id);
          return imageUrl;
        } else {
          print("No se pudo obtener la URL de la imagen del perfil");
          return null;
        }
      } else {
        print("No se ha seleccionado nada");
        return null;
      }
    } catch (error) {
      print("Error al subir la foto de perfil: $error");
      return null;
    }
  }

  @override
  Future<PostgrestList> getContent(
      User user, String table, String field) async {
    PostgrestList profilePicture;
    profilePicture = await supabase
        .from("user")
        .select("profile_picture")
        .eq("id_user", user.id);
    // print(profilePicture);
    return profilePicture;
  }
}
