import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  // Use local backend URL for development. Change this to a deployed production URL later.
  static String get baseUrl {
    return 'https://women-safety-j9ok.onrender.com/api';
  }

  static String get wsUrl {
    return 'https://women-safety-j9ok.onrender.com';
  }
}
