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
import 'package:fernweh/common/utils.dart';
import 'package:fernweh/screens/similarities.dart';

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
        fontFamily: "monospace",
      ),
      routes: {
        "/": (context) => const AuthGate(),
        "/login": (context) => LoginScreen(),
        "/register": (context) => RegisterScreen(),
        "/home": (context) => HomeScreen(),
        "/profile": (context) => ProfileScreen(),
        "/diary": (context) => DiaryScreen(),
        "/posts": (context) => PostsScreen(),
        "/post": (context) => PostScreen(),
        "/confirm": (context) => ConfirmScreen(),
        "/icon": (context) => Icon(Icons.home),
        "/similarities": (context) => SimilaritiesScreen(),
      },
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late Future<bool> _skipLoginFuture;

  @override
  void initState() {
    super.initState();
    _skipLoginFuture = shouldSkipLogin(context);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _skipLoginFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          print("AuthGate Error: ${snapshot.error}");
          return Scaffold(
            body: Center(child: Text("An error occurred: ${snapshot.error}")),
          );
        }

        if (snapshot.hasData && snapshot.data == true) {
          print("AuthGate: Success, skipping login.");
          return HomeScreen();
        } else {
          return LoginScreen();
        }
      },
    );
  }
}
