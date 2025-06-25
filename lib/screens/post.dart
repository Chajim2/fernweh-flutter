import 'dart:convert';

import 'package:fernweh/common/common_widgets.dart';
import 'package:fernweh/common/utils.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fernweh/providers/user_provider.dart';
import 'package:provider/provider.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _PostsScreenState();
  }
}

class _PostsScreenState extends State<PostScreen> {
  bool loadingComments = true;
  TextEditingController _commnentController = TextEditingController();
  List<dynamic> comments = [];
  
  Future<void> getComments() async {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final response = await http.post(
      Uri.parse("https://chajim.pythonanywhere.com/get_comments"),
      headers: DEFAULT_HEADER,
      body: jsonEncode({
        "id": Provider.of<UserProvider>(context, listen: false).getJwtToken(),
        "entry_id": args['id'],
      }),
    );
    try {
      if (response.statusCode == 200) {
        comments = jsonDecode(response.body)['comments'];
        setState(() {
          loadingComments = false;
        });
        print(jsonDecode(response.body)['message']);
      } else {
        throw Exception(
          'Failed to load comments: ${jsonDecode(response.body)['message']}',
        );
      }
    } catch (e) {
      setState(() {
        loadingComments = false;
      });
      print('Error fetching comments: $e');
    }
    return;
  }

  Future<void> postComment(BuildContext context) async {
    final args =
            ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final response = await http.post(
      Uri.parse("https://chajim.pythonanywhere.com/post_comment"),
      headers: DEFAULT_HEADER,
      body: jsonEncode({
        "id": Provider.of<UserProvider>(context, listen: false).getJwtToken(),
        "post_id": args['id'],
        "text" : _commnentController.text,
      }),
    );
    try {
      if (response.statusCode == 201) {
        setState(() {
          loadingComments = false;
        });
        showStyledAlert(context, "commnent", "comment posted");
      } else {
        throw Exception(
          'Failed to post comment: ${jsonDecode(response.body)['message']}',
        );
      }
    } catch (e) {
      setState(() {
        loadingComments = false;
      });
      print('Error posting comment: $e');
    }
    return;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getComments();
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF1E1E1E);
    const accentColor = Color(0xFFFFB74D);
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Padding(
                padding: const EdgeInsets.only(top: 60), // replace SizedBox
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      args['title'] ?? "",
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Georgia',
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      args['text'] ?? "",
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: 40,),

                    Text(
                      "comments",
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Georgia',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Column(
                      children: comments
                          .map(
                            (comment) => PostCard(
                              title: "",
                              author: comment['author'],
                              content: comment['text'],
                              onTap: () {},
                            ),
                          )
                          .toList(),
                    ),
                    CommonTextInput(hintText: "write your comment...", controller: _commnentController),
                    CommonButton(text: "comment", onPressed: () => postComment(context)),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                color: accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
