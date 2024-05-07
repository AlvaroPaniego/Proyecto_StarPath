import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';

class UserProvider extends ChangeNotifier{
  User? user;
  UserProvider();

  void setLoggedUser({required User newUser}) async{
    user = newUser;
    notifyListeners();
  }
}