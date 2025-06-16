import 'package:flutter/material.dart';


class UserProvider extends ChangeNotifier {
  String username;
  String jwtToken;
  bool logedIn;

  UserProvider({this.username = "", this.jwtToken = "", this.logedIn = false});

  void logOut(){
    username = "";
    jwtToken = "";
    logedIn = false;
    notifyListeners();
  }

  void logIn({required String newUsername, required String jwtToken}) {
      username = newUsername;
      this.jwtToken = jwtToken;
      logedIn = true;
      notifyListeners();
  }

  String getUsername(){
    return username;
  }

  String getJwtToken(){
    return jwtToken;
  }

}
