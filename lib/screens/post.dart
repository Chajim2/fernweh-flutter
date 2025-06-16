import 'package:flutter/material.dart';
import 'package:fernweh/providers/user_provider.dart';
import 'package:provider/provider.dart';

class PostScreen extends StatefulWidget{
  const PostScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _PostsScreenState();
  }
}

class _PostsScreenState extends State<PostScreen>{
  bool loadingComments = true;
  
  Future<void> getComments() async{
    return;
  }

  Future<void> setValues(String title, String author, String text) async{
    
  }

  @override
  void initState(){
    super.initState();
    getComments();
  }
  
  @override
  Widget build(BuildContext context){
    const backgroundColor = Color(0xFF1E1E1E);
    const accentColor = Color(0xFFFFB74D);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Top-left back icon
            Positioned(
              top: 10,
              left: 10,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                color: accentColor,
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  Text(
                    Provider.of<UserProvider>(
                      context,
                      listen: false,
                    ).getUsername(),
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'Georgia',
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ]
              )
            )
          ]
        )
      )
    );
  }
}