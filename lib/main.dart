import 'package:fernweh/screens/diary.dart';
import 'package:fernweh/screens/home.dart';
import 'package:fernweh/screens/post.dart';
import 'package:fernweh/screens/profile.dart';
import 'package:fernweh/screens/register.dart';
import 'package:fernweh/screens/posts.dart';
import 'package:flutter/material.dart';
import 'package:fernweh/screens/login.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'package:fernweh/screens/confirm.dart';

void main() {
  runApp(
    ChangeNotifierProvider(create: (context) => UserProvider(), child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.amber,
        fontFamily: "Fantasy",
      ),
      routes: {
        "/": (context) => LoginScreen(),
        "/register": (context) => RegisterScreen(),
        "/home" : (context) => HomeScreen(),
        "/profile" : (context) => ProfileScreen(),
        "/diary" : (context) => DiaryScreen(),
        "/posts" : (context) => PostsScreen(),
        "/post" : (context) => PostScreen(),
        "/confirm" : (context) => ConfirmScreen(),
      },
    );
  }
}
