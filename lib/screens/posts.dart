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

  Future<void> handleClickedPost(
    String text,
    String title,
    String author,
    int entryId,
  ) async {
    Map<String, dynamic> data = {
      "text": text,
      "title": title,
      "author": author,
      "id": entryId,
    };
    Navigator.pushNamed(context, "/post", arguments: data);
    return;
  }

  Future<void> handleClickedComment(int entryId) async {
    const String url = 'https://chajim.pythonanywhere.com/get_post_with_title';
    final response = await http.post(
      Uri.parse(url),
      headers: DEFAULT_HEADER,
      body: jsonEncode({
        "id": Provider.of<UserProvider>(context, listen: false).getJwtToken(),
        "entry_id": entryId,
      }),
    );
    if (response.statusCode != 200) {
      print("Failed fetching post by id");
      return;
    }
    Map<String, dynamic> data = jsonDecode(response.body)['post'];
    Navigator.pushNamed(
      context,
      "/post",
      arguments: {
        "id": data['id'],
        "text": data['text'],
        'author': data['author'],
        'title': data['title'],
      },
    );
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
        throw Exception('Failed to load posts');
      }
    } catch (e) {
      setState(() {
        isLoadingPosts = false;
      });
      print('Error fetching posts: $e');
    }
    ;
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
                    onTap: () => handleClickedPost(
                      entry['text'],
                      entry['emotions'].join(", "),
                      entry['username'],
                      entry['id'],
                    ),
                  );
                } else if (entry['username'] ==
                    Provider.of<UserProvider>(
                      context,
                      listen: false,
                    ).getUsername()) {
                  return PostCard(
                    title: "you commented on this post",
                    author: "you",
                    content: entry['text'],
                    onTap: () => handleClickedComment(entry['id']),
                  );
                } else {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal:
                          MediaQuery.of(context).size.width *
                          0.1, // 10% of screen width
                    ),
                    child: PostCard(
                      title: "${entry['username']} commented on this post",
                      author: entry['username'],
                      content: entry['text'],
                      onTap: () => handleClickedComment(entry['id']),
                    ),
                  );
                }
              },
            ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    );
  }
}
