import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fernweh/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;

const Map<String, String> DEFAULT_HEADER = {'Content-Type': 'application/json'};
const String refresh_key = "this_is_magic";
const String username_key = "this_is_also_magic";
final secure_storage = FlutterSecureStorage();

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
                side: const BorderSide(color: Color(0xFFFFB74D), width: 1.2),
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

void setCookie(String name, String value) {
  html.document.cookie = '$name=$value; path=/; max-age=31536000';
}

String? getCookie(String name) {
  final cookies = html.document.cookie?.split('; ') ?? [];
  for (var cookie in cookies) {
    final parts = cookie.split('=');
    if (parts.length == 2 && parts[0] == name) return parts[1];
  }
  return null;
}

bool hasCookies() {
  final cookieString = html.document.cookie;
  return cookieString != null && cookieString.isNotEmpty;
}

Future<bool> shouldSkipLogin(BuildContext context) async {
  String refreshUrl = "https://chajim.pythonanywhere.com/refresh";
  String? refreshToken;
  String? username;
  if (kIsWeb) {
    if (await hasCookies()) {
      refreshToken = getCookie("refresh_token");
      username = getCookie("username");
    } else
      return false;
  } else {
    refreshToken = await secure_storage.read(key: refresh_key);
    username = await secure_storage.read(key: username_key);
  }
  try {
    //showStyledAlert(context, "HAHA", refreshToken ?? "");

    final response = await http.post(
      Uri.parse(refreshUrl),
      body: jsonEncode({"refresh_token": refreshToken ?? ""}),
      headers: DEFAULT_HEADER,
    );
    //showStyledAlert(context, "HAHA", response.statusCode as String ?? "nun");

    if (response.statusCode == 200) {
      print("Token refresh successful.");
      Map<String, dynamic> jsonData = jsonDecode(response.body);
      Provider.of<UserProvider>(
        context,
        listen: false,
      ).logIn(newUsername: username ?? "", jwtToken: jsonData['auth_token']);
      return true;
    } else {
      print("Token refresh failed with status: ${response.statusCode}");
    }
  } catch (e) {
    print("!!! EXCEPTION in shouldSkipLogin: $e");
  }
  return false;
}

Future<void> saveRefreshData(String refresh_token, String username) async {
  if (kIsWeb) {
    setCookie("refresh_token", refresh_token);
    setCookie("username", username);
  } else {
    await secure_storage.write(key: refresh_key, value: refresh_token);
    await secure_storage.write(key: username_key, value: username);
  }
}
