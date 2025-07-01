import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fernweh/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:fernweh/common/common_widgets.dart';
import 'package:fernweh/common/utils.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController1 = TextEditingController();
  final TextEditingController passwordController2 = TextEditingController();
  final String registerUrl = "https://chajim.pythonanywhere.com/register";

  void handleRegister(BuildContext context) async {
    String username = usernameController.text;
    String password1 = passwordController1.text;
    String password2 = passwordController2.text;
    if (username.length < 2) {
      showStyledAlert(context, "invalid register", 'invalid username');
    } else if (password1.length < 5) {
      showStyledAlert(context, "invalid register", 'invalid password');
    } else if (password1 != password2) {
      showStyledAlert(context, "invalid register", "passwords dont match");
    } else {
      final response = await http.post(
        Uri.parse(registerUrl),
        body: jsonEncode({"username": username, "password": password1}),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 201) {
        showStyledAlert(context, "sucessfull register", "please log in");
      } else {
        showStyledAlert(context, "register unsucesfull", "username taken");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("register"), leading: Icon(Icons.login)),
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
                    controller: passwordController1,
                  ),
                ),
                SizedBox(
                  width: 250,
                  child: CommonPasswordInput(
                    hintText: "password again",
                    controller: passwordController2,
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: CommonButton(
                    text: "register",
                    onPressed: () => handleRegister(context),
                  ),
                ),
                SizedBox(height: 80),
                Text("already have an account?"),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SizedBox(
                    width: 200,
                    child: CommonButton(
                      text: "login",
                      onPressed: () => Navigator.pushNamed(context, "/login"),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
