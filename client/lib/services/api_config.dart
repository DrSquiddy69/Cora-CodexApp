import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  ApiConfig._();

  static final ApiConfig instance = ApiConfig._();
  static const _key = 'api_base_url';
  static const androidEmulatorBaseUrl = 'http://10.0.2.2:8080';
  static const desktopDefaultBaseUrl = 'http://127.0.0.1:8080';

  String _baseUrl = '';

  String get baseUrl => _baseUrl;

  bool get hasBaseUrl => _baseUrl.trim().isNotEmpty;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_key);
    _baseUrl = _sanitize(stored ?? '');
    if (_baseUrl.isEmpty && _isDesktopPlatform()) {
      _baseUrl = desktopDefaultBaseUrl;
    }
  }

  Future<void> saveBaseUrl(String value) async {
    _baseUrl = _sanitize(value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, _baseUrl);
  }

  String _sanitize(String value) => value.trim().replaceAll(RegExp(r'/+$'), '');

  bool _isDesktopPlatform() {
    return defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux;
  }
}
