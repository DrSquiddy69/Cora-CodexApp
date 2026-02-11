import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  ApiConfig._();

  static final ApiConfig instance = ApiConfig._();
  static const _key = 'api_base_url';
  static const defaultBaseUrl = 'http://10.0.2.2:8080';

  String _baseUrl = defaultBaseUrl;

  String get baseUrl => _baseUrl;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _baseUrl = prefs.getString(_key) ?? defaultBaseUrl;
  }

  Future<void> saveBaseUrl(String value) async {
    final sanitized = value.trim().replaceAll(RegExp(r'/+$'), '');
    _baseUrl = sanitized.isEmpty ? defaultBaseUrl : sanitized;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, _baseUrl);
  }
}
