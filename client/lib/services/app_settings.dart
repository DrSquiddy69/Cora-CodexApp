import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  AppSettings._();

  static const _enterToSendKey = 'enter_to_send';
  static bool enterToSend = true;

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    enterToSend = prefs.getBool(_enterToSendKey) ?? true;
  }

  static Future<void> setEnterToSend(bool value) async {
    enterToSend = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enterToSendKey, value);
  }
}
