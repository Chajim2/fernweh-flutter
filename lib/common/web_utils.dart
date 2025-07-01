import 'dart:html' as html;

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

void deleteCookies() {}
