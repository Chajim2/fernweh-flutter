import 'package:flutter/material.dart';

class CommonTextInput extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final bool obscureText;

  const CommonTextInput({
    required this.hintText,
    required this.controller,
    this.obscureText = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            height: 1.5,
          ),
          cursorColor: const Color(0xFFFFB74D), // Warm amber accent
          maxLines: obscureText ? 1 : null,
          keyboardType: obscureText
              ? TextInputType.visiblePassword
              : TextInputType.multiline,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF1C1C1C), // deep charcoal background
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[800]!, width: 1.2),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFFFB74D), width: 1.8),
            ),
          ),
        ),
      ),
    );
  }
}

class CommonPasswordInput extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;

  const CommonPasswordInput({
    required this.hintText,
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CommonTextInput(
      hintText: hintText,
      controller: controller,
      obscureText: true,
    );
  }
}

class CommonButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const CommonButton({required this.text, required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () {
          onPressed();
        },
        style: TextButton.styleFrom(
          backgroundColor: Color(0xFF2B2B2B), // dark background
          foregroundColor: Colors.white, // text color
          padding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 21, // was 14, increased by 50%
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero, // no rounded corners
            side: BorderSide(
              color: Color(0xFFFFB74D), // warm amber border
              width: 1.4,
            ),
          ),
          textStyle: TextStyle(
            fontSize: 16,
            fontFamily: "Fantasy",
            fontWeight: FontWeight.w500,
          ),
        ),
        child: Text(text),
      ),
    );
  }
}

class FriendCard extends StatelessWidget {
  final String name;
  final VoidCallback? onTap;

  const FriendCard({super.key, required this.name, this.onTap});

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFFFFB74D); // warm amber

    return Card(
      color: const Color(0xFF2A2A2A),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: const BorderSide(color: accentColor, width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        leading: const Icon(Icons.person, color: accentColor),
        title: Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Georgia',
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.white54,
        ),
        onTap: onTap,
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final String title;
  final String author;
  final String content;
  final VoidCallback? onTap;

  const PostCard({
    super.key,
    required this.title,
    required this.author,
    required this.content,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFFFFB74D); // Warm amber border
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
        maxWidth: 600,
        ),
        child: GestureDetector(
          onTap: onTap,
            child: Card(
              color: const Color(0xFF2A2A2A),
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
                side: const BorderSide(color: accentColor, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16, // Smaller font for title
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          author,
                          style: const TextStyle(
                            fontSize: 13, // Smaller font for author
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      content.length > 220
                          ? "${content.substring(0, 220)}..."
                          : content,
                      style: const TextStyle(
                        fontSize: 15, // Smaller font for content
                        color: Colors.white70,
                      ),
                      maxLines: 6, // Adjusted for longer text
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            )
        ),
      ),
    );

  }
}

class DefinitionCard extends StatelessWidget {
  final String word;
  final String definition;
  final VoidCallback onTap;

  const DefinitionCard({
    super.key,
    required this.word,
    required this.definition,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        color: Theme.of(context).cardColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                word,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  definition,
                  style: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}