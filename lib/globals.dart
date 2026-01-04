// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'dart:io' show Platform;

// Base URL for your live API domain
const String _baseURL = 'pulse.rf.gd';

String buildHost() {
  // Always use your real domain now
  return _baseURL;
}

Uri buildUri(String path) {
  final host = buildHost();

  // InfinityFree enforces HTTPS, so always use Uri.https
  return Uri.https(host, 'parentpal_api/$path');
}

class Globals {
  static String? token;
  static int? userId;
  static String? username; // added for showing in AppBar
}
