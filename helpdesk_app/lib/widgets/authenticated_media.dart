import 'package:flutter/painting.dart';

import '../services/api_config.dart';

/// Centralizes authenticated media loading so screens do not handle API config.
abstract class AuthenticatedMedia {
  static Map<String, String> get headers => ApiConfig.mediaHeaders;

  static String resolveUrl(String url) => ApiConfig.resolveMediaUrl(url);

  static ImageProvider imageProvider(String url) =>
      NetworkImage(resolveUrl(url), headers: ApiConfig.mediaHeaders);
}
