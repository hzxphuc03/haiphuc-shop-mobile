import 'dart:io';
import 'package:flutter/foundation.dart';

enum Environment { dev, prod }

class EnvConfig {
  static const String _env = String.fromEnvironment('ENV', defaultValue: 'dev');

  static Environment get current {
    switch (_env) {
      case 'prod':
        return Environment.prod;
      default:
        return Environment.dev;
    }
  }

  static String get baseUrl {
    if (current == Environment.prod) {
      return 'https://haiphuc-shop-server.onrender.com/api/v1';
    }

    // Development Base URL
    // Special handling for local development on different platforms
    if (kIsWeb) {
      return 'http://localhost:5005/api/v1';
    }
    
    if (Platform.isAndroid) {
      // Android emulator uses 10.0.2.2 to access host's localhost
      return 'http://10.0.2.2:5005/api/v1';
    }
    
    // iOS Simulator and others
    return 'http://localhost:5005/api/v1';
  }

  static bool get isDev => current == Environment.dev;
  static bool get isProd => current == Environment.prod;
}
