import 'package:flutter/material.dart';
import 'package:fernweh/common/common_widgets.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fernweh/common/utils.dart';
import 'package:provider/provider.dart';
import 'package:fernweh/providers/user_provider.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final TextEditingController _diaryController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool receivedEmotions = false;
  List<dynamic> emotions = [];
  List<String> confirmedEmotions = [];
  bool emotionClicked = false;

  @override
  void dispose() {
    _diaryController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void handleClickedEmotion(int emotionInd) {
    confirmedEmotions.add(emotions[emotionInd]['emotion'].trim());
    emotions.removeAt(emotionInd);
    print(confirmedEmotions);
    setState(() {
      emotionClicked = true;
    });
  }

  Future<void> _fetchEmotions(String text) async {
    const String url = 'https://chajim.pythonanywhere.com/get_emotions';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: DEFAULT_HEADER,
        body: jsonEncode({
          "id": Provider.of<UserProvider>(context, listen: false).getJwtToken(),
          "text": _diaryController.text.trim(),
        }),
      );
      if (response.statusCode == 200) {
        emotions = jsonDecode(response.body)['emotions'];
        setState(() {
          receivedEmotions = true;
        });
      } else {
        throw Exception(
          'Failed to load requests, ${jsonDecode(response.body)['message']}',
        );
      }
    } catch (e) {
      setState(() {
        receivedEmotions = false;
      });
      print('Error fetching requests: $e');
    }
    //TODO 1. send the request, 2. display the emotions, 3. refresh when one is chosen/reloaded, 4.save all of it
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF1E1E1E);
    const accentColor = Color(0xFFFFB74D);
    const textColor = Colors.white70;


    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top navigation bar
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
                  if(emotionClicked)SizedBox(width: 30),
                  Text(
                    'Journal Entry',
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 18,
                      fontFamily: 'Georgia',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  // Empty container for spacing
                  if(!emotionClicked) SizedBox(width: 48),
                  if (emotionClicked)
                    CommonButton(
                      text: "Continue",
                      onPressed: () {
                        Navigator.pushNamed(context, "/confirm", arguments: {"emotions" : confirmedEmotions, "text" : _diaryController.text});
                      },
                    ),
                ],
              ),
            ),
            // Main content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    // Date display
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Text(
                        _getCurrentDate(),
                        style: const TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontFamily: 'Georgia',
                        ),
                      ),
                    ),
                    // Large text field
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: accentColor.withOpacity(0.3),
                            width: 1.2,
                          ),
                          borderRadius: BorderRadius.zero,
                        ),
                        child: TextField(
                          controller: _diaryController,
                          focusNode: _focusNode,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          style: const TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontFamily: 'Georgia',
                            height: 1.5,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Write your thoughts here...',
                            hintStyle: TextStyle(
                              color: textColor.withOpacity(0.5),
                              fontFamily: 'Georgia',
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          cursorColor: accentColor,
                        ),
                      ),
                    ),
                    //check if emotions were received
                    receivedEmotions
                        ? Column(
                            children: emotions
                                .take(3)
                                .map(
                                  (pair) => DefinitionCard(
                                    word: pair['emotion'].trim() ?? "",
                                    definition: pair['description'] ?? "",
                                    onTap: () {
                                      handleClickedEmotion(
                                        emotions.indexOf(pair),
                                      );
                                    },
                                  ),
                                )
                                .toList(),
                          )
                        : Column(
                            children: [
                              const SizedBox(height: 20),
                              // Save button
                              CommonButton(
                                text: 'Save Entry',
                                onPressed: () async {
                                  _fetchEmotions("afsian");
                                },
                              ),

                              const SizedBox(height: 20),
                            ],
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }
}
