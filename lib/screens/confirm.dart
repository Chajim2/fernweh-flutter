import 'package:flutter/material.dart';
import 'package:fernweh/common/common_widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fernweh/common/utils.dart';
import 'package:provider/provider.dart';
import 'package:fernweh/providers/user_provider.dart';

//implement confirm screen, use show styled alert, it looks sick!!!
class ConfirmScreen extends StatefulWidget {
  const ConfirmScreen({super.key});

  @override
  State<ConfirmScreen> createState() => _ConfirmScreenState();
}

class _ConfirmScreenState extends State<ConfirmScreen> {
  bool isSaved = false;
  Future<void> _handlePressed(BuildContext context) async {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    const String url = 'https://chajim.pythonanywhere.com/save_entry';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: DEFAULT_HEADER,
        body: jsonEncode({
          "id": Provider.of<UserProvider>(context, listen: false).getJwtToken(),
          "text": args['text'].trim(),
          "emotions": args['emotions'],
        }),
      );
      if (response.statusCode == 201) {
        setState(() {
          isSaved = true;
        });
        Navigator.pushNamed(context, "/home");
        showStyledAlert(
          context,
          "Post saved",
          jsonDecode(response.body)['message'],
        );
      } else {
        throw Exception(
          'Failed to save post, ${jsonDecode(response.body)['message']}',
        );
      }
    } catch (e) {
      setState(() {
        isSaved = false;
      });
      print('Error fetching requests: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF1E1E1E);
    const accentColor = Color(0xFFFFB74D);
    //const textColor = Colors.white70;
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                    color: accentColor,
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SelectableText(
                        args['emotions'].join(", "),
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Georgia',
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 40),

                      SelectableText(
                        args['text'],
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white70,
                        ),
                      ),
                      SizedBox(height: 40),

                      CommonButton(
                        text: "Post",
                        onPressed: () {
                          _handlePressed(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
