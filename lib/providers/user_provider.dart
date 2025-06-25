import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String _username;
  String _jwtToken;
  bool _loggedIn;

  UserProvider({
    String username = "",
    String jwtToken = "",
    bool loggedIn = false,
  })  : _username = username,
        _jwtToken = jwtToken,
        _loggedIn = loggedIn;

  String get username => _username;
  String get jwtToken => _jwtToken;
  bool get loggedIn => _loggedIn;

  void logOut() {
    _username = "";
    _jwtToken = "";
    _loggedIn = false;
    notifyListeners();
  }

  String getUsername(){
    return _username;
  }

  String getJwtToken(){
    return _jwtToken;
  }

  void logIn({required String newUsername, required String jwtToken}) {
    _username = newUsername;
    _jwtToken = jwtToken;
    _loggedIn = true;
    notifyListeners();
  }
}
