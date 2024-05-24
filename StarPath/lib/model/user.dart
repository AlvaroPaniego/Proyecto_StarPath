import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';

class UserProvider extends ChangeNotifier {
  User? _user;
  String? _profilePictureUrl;

  User? get user => _user;
  String? get profilePictureUrl => _profilePictureUrl;

  void setLoggedUser({required User newUser}) {
    _user = newUser;
    notifyListeners();
  }

  void updateProfilePictureUrl(String newUrl) {
    _profilePictureUrl = newUrl;
    notifyListeners();
  }
}
