import 'package:flutter/material.dart';

Map<String,String> DEFAULT_HEADER = {'Content-Type': 'application/json'};

void showStyledAlert(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color(0xFF2B2B2B), // dark background
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, // sharp corners
          side: const BorderSide(
            color: Color(0xFFFFB74D), // warm amber border
            width: 1.4,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Georgia',
            color: Colors.white,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 15,
            fontFamily: 'Georgia',
            color: Colors.white70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFFB74D),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
                side: const BorderSide(
                  color: Color(0xFFFFB74D),
                  width: 1.2,
                ),
              ),
              textStyle: const TextStyle(
                fontFamily: 'Georgia',
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}


