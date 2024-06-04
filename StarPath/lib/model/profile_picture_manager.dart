import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:starpath/Services/file_chooser.dart';
import 'package:starpath/misc/constants.dart';
import 'package:supabase/supabase.dart';
import 'package:starpath/model/user.dart';

class ProfilePictureManager implements FileChooser {
  final SupabaseClient supabase = SupabaseClient(supabaseURL, supabaseKey);

  @override
  Future<String?> uploadContent(
      User user, String filePath, String fileName) async {
    try {
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(type: FileType.media);
      if (result != null) {
        String file = result.names[0]!;
        String path = result.paths[0]!;

        CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: path,
          maxWidth: 100,
          maxHeight: 100,
          aspectRatioPresets: [
            CropAspectRatioPreset.ratio4x3,
          ],
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Recortar imagen',
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: true,
            ),
            IOSUiSettings(title: 'Recortar imagen'),
          ],
        );

        if (croppedFile != null) {
          print('imagen: ${croppedFile.path}');
          File croppedFileAsFile = File(croppedFile.path);
          String storagePath = 'profile_pictures/${user.id}/${croppedFile.path}';

          await supabase.storage.from('pruebas').upload(
              storagePath, croppedFileAsFile,
              fileOptions: const FileOptions(upsert: true));
          var response =
              await supabase.storage.from('pruebas').getPublicUrl(storagePath);

          if (response != null) {
            String imageUrl = response!;
            await supabase
                .from('user')
                .update({'profile_picture': imageUrl}).eq('id_user', user.id);
            return imageUrl;
          } else {
            print('Error al obtener la URL pública de la imagen');
            return null;
          }
        } else {
          print('No se pudo recortar la imagen');
          return null;
        }
      } else {
        print('No se ha seleccionado nada');
        return null;
      }
    } catch (error) {
      print('Error al subir la foto de perfil: $error');
      return null;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getContent(
      User user, String table, String field) async {
    final response =
        await supabase.from(table).select(field).eq('id_user', user.id);
    return response;
  }
}
