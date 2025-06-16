import 'package:fernweh/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:fernweh/common/common_widgets.dart';
import 'package:fernweh/common/utils.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final String loginUrl = "https://chajim.pythonanywhere.com/login";

  LoginScreen({super.key});


  void handleLogin(BuildContext context) async{
    String username = usernameController.text;
    String password = passwordController.text;
    if (username.length < 2) {
      showStyledAlert(context, "invalid login", 'invalid username');
    } else if (password.length < 5) {
      showStyledAlert(context, "invalid login", 'invalid password');
    } else{
      final response = await http.post(
        Uri.parse(loginUrl),
        body: jsonEncode({"username": username, "password": password}),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        //TODO: acces id token in json and set it into provider, navigate to home screen (doesnt exist yet :D)
        Map<String, dynamic> jsonData = jsonDecode(response.body);
        print("LOGGING IN HERE");
        print(jsonData['id']);
        Provider.of<UserProvider>(context, listen: false).logIn(newUsername: username, jwtToken: jsonData['id']);
        Navigator.pushNamed(context, "/home");
      } else {
        showStyledAlert(context, "login unsucesfull", jsonDecode(response.body)['message']);
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login"), leading: Icon(Icons.login)),
      body: Consumer<UserProvider>(
        builder: (context, UserProvider, child) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 250,
                  child: CommonTextInput(
                    hintText: "username",
                    controller: usernameController,
                  ),
                ),
                SizedBox(
                  width: 250,
                  child: CommonPasswordInput(
                    hintText: "password",
                    controller: passwordController,
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: CommonButton(
                    text: "asfas",
                    onPressed: () => handleLogin(context),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SizedBox(
                    width: 200,
                    child: CommonButton(
                      text: "Register\ninstead",
                      onPressed: () => Navigator.pushNamed(context, "/register"),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }
}
