import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:fernweh/common/utils.dart';
import 'package:fernweh/common/common_widgets.dart';
import 'package:fernweh/providers/user_provider.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  bool isLoadingPosts = true;
  Map<String, dynamic> posts = {};

  @override
  void initState() {
    super.initState();
    getPosts(context);
  }

  Future<void> handleClicked(BuildContext context, String text, String title, String author) async{
    Navigator.pushNamed(context, "/post");
    return;
  }

  Future<void> getPosts(BuildContext context) async {
    const String url = 'https://chajim.pythonanywhere.com/get_all_entries';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: DEFAULT_HEADER,
        body: jsonEncode({
          "id": Provider.of<UserProvider>(context, listen: false).getJwtToken(),
        }),
      );
      if (response.statusCode == 200) {
        posts = jsonDecode(response.body);
        setState(() {
          isLoadingPosts = false;
        });
      } else {
        throw Exception('Failed to load requests');
      }
    } catch (e) {
      setState(() {
        isLoadingPosts = false;
      });
      print('Error fetching requests: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFFFFB74D); // warm amber

    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
        centerTitle: true,
        elevation: 0,
      ),
      body: isLoadingPosts
          ? const Center(child: CircularProgressIndicator(color: accentColor))
          : ListView.builder(
              itemCount: posts['entries']?.length ?? 0,
              itemBuilder: (context, index) {
                final entry = posts['entries'][index];
                if (entry['type'] == 'post') {
                  return PostCard(
                    title: entry['emotions'].join(", "),
                    author: entry['username'],
                    content: entry['text'],
                    onTap: () => handleClicked(context, entry['text'], entry['emotions'].join(", "), entry['username']),
                  );
                } else if (entry['username'] ==
                    Provider.of<UserProvider>(
                      context,
                      listen: false,
                    ).getUsername()){
                  return PostCard(
                    title: "you commented on this post",
                    author: "you",
                    content: entry['text'],
                    onTap: () => handleClicked(context, entry['text'], "${entry['usernmae']} commented", entry['username']),
                  );
                } else{
                  return PostCard(
                    title: "${entry['username']} commented on this post",
                    author: entry['username'],
                    content: entry['text'],
                    onTap: () => handleClicked(context, entry['text'], "You commented", entry['username']),
                  );
                }
              },
            ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    );
  }
}

