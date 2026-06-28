import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  // Use local backend URL for development. Change this to a deployed production URL later.
  static String get baseUrl {
    return 'https://excuse-unified-appropriations-continuing.trycloudflare.com/api';
  }

  static String get wsUrl {
    return 'https://excuse-unified-appropriations-continuing.trycloudflare.com';
  }
}
