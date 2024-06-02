import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
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
        String file = result.names[0]!;
        String path = result.paths[0]!;

        CroppedFile? croppedFile = await ImageCropper()
            .cropImage(sourcePath: path, aspectRatioPresets: [
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ], uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Recortar imagen',
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(
            title: 'Recortar imagen',
          ),
        ]);

        if (croppedFile != null) {
          File croppedFileAsFile = File(croppedFile.path!);

          await supabase.storage.from("pruebas").upload(file, croppedFileAsFile,
              fileOptions: const FileOptions(upsert: true));
          var res = await supabase.storage.from("pruebas").getPublicUrl(file);
          String? imageUrl = res;
          if (imageUrl != null) {
            await supabase
                .from("user")
                .update({"profile_picture": imageUrl}).eq("id_user", user.id);
          } else {
            print("No se pudo obtener la URL de la imagen del perfil");
          }
        } else {
          print("No se pudo recortar la imagen");
        }
      } else {
        print("No se ha seleccionado nada");
      }
    } catch (error) {
      print("Error al subir la foto de perfil: $error");
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
    return profilePicture;
  }
}
