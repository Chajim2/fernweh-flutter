import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:fernweh/common/utils.dart';
import 'package:fernweh/common/common_widgets.dart';
import 'package:fernweh/providers/user_provider.dart';

class SimilaritiesScreen extends StatefulWidget {
  const SimilaritiesScreen({super.key});

  @override
  State<SimilaritiesScreen> createState() => _SimilaritiesScreenState();
}

class _SimilaritiesScreenState extends State<SimilaritiesScreen> {
  bool isLoading = true;
  // Data returned from the backend for the similar posts
  List<dynamic> similar_post_data = [];
  // IDs of similar posts coming from the previous screen
  List<int> similar_posts = [];
  bool _hasFetched = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> handleClickedPost(int entryId) async {
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

  Future<void> fetchSimilarPosts() async {
    debugPrint("fetching similar posts for IDs: $similar_posts");
    const String url = 'https://chajim.pythonanywhere.com/batch_get_posts';
    final response = await http.post(
      Uri.parse(url),
      headers: DEFAULT_HEADER,
      body: jsonEncode({
        "id": Provider.of<UserProvider>(context, listen: false).getJwtToken(),
        "entry_ids": similar_posts,
      }),
    );
    if (response.statusCode == 200) {
      similar_post_data = jsonDecode(response.body)['posts'];
      print("similar posts: ${jsonDecode(response.body)}");
      setState(() {
        isLoading = false;
      });
    } else {
      throw Exception('Failed to fetch similar posts');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasFetched) {
      _hasFetched = true;
      // Read IDs once from the route arguments and store them in state
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      final rawIds = args?['similar_posts'] ?? args?['similiar_posts'];
      if (rawIds is List) {
        similar_posts = rawIds
            .map((e) => e is int ? e : int.tryParse(e.toString()))
            .whereType<int>()
            .toList();
      }
      fetchSimilarPosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF1E1E1E);
    const accentColor = Color(0xFFFFB74D); // warm amber
    debugPrint("got to similarities with IDs: $similar_posts");
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/home',
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.arrow_forward),
                    color: accentColor,
                  ),
                ],
              ),
            ),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator(color: accentColor))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: similar_post_data.length,
                      itemBuilder: (context, index) {
                        final post = similar_post_data[index];
                        final map = post is Map<String, dynamic>
                            ? post
                            : Map<String, dynamic>.from(post as Map);
                        final title = map['title']?.toString() ?? '';
                        final author = map['author']?.toString() ?? '';
                        final content = map['text']?.toString() ?? '';
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: PostCard(
                            title: title.isNotEmpty ? title : 'Similar post',
                            author: author,
                            content: content,
                            onTap: () => handleClickedPost(map['id']),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
