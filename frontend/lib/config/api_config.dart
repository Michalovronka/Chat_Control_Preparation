import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  // Get the base URL based on the platform
  static String get baseUrl {
    if (kIsWeb) {
      // Web platform - use localhost
      return 'http://localhost:5202';
    } else if (Platform.isAndroid) {
      // Android emulator uses 10.0.2.2 to access host machine
      // For physical devices, you may need to use your actual IP address
      return 'http://10.0.2.2:5202';
    } else if (Platform.isIOS) {
      // iOS simulator can use localhost
      // For physical devices, you may need to use your actual IP address
      return 'http://localhost:5202';
    } else {
      // Desktop platforms
      return 'http://localhost:5202';
    }
  }

  // Helper method to get the full API URL
  static String getApiUrl(String endpoint) {
    // Remove leading slash if present to avoid double slashes
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    return '$baseUrl/api/$cleanEndpoint';
  }

  // Helper method to get the full URL for non-API endpoints (like SignalR hubs)
  static String getUrl(String path) {
    // Remove leading slash if present to avoid double slashes
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return '$baseUrl/$cleanPath';
  }
}
