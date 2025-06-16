import 'package:flutter/material.dart';
import 'package:fernweh/common/common_widgets.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final TextEditingController _diaryController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _diaryController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _saveDiary() {
    // Handle saving diary entry
    String diaryText = _diaryController.text.trim();
    if (diaryText.isNotEmpty) {
      // Add your save logic here
      print('Saving diary entry: $diaryText');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Diary entry saved!'),
          backgroundColor: Color(0xFFFFB74D),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
                  const SizedBox(width: 48),
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
                    const SizedBox(height: 20),
                    // Save button
                    CommonButton(
                      text: 'Save Entry',
                      onPressed: _saveDiary,
                    ),
                    const SizedBox(height: 20),
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
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }
}