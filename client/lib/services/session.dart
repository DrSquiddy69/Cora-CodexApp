import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';
import 'cora_api_service.dart';

class Session {
  Session._();

  static const _key = 'current_user';
  static AppUser? currentUser;

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return;
    currentUser = AppUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  static Future<void> setCurrentUser(AppUser user) async {
    currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(user.toJson()));
  }

  static Future<void> clear() async {
    currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Future<void> refreshFromBackend(CoraApiService api) async {
    if (currentUser == null) return;
    try {
      final refreshed = await api.me(currentUser!.email);
      await setCurrentUser(refreshed);
    } catch (_) {
      // Keep existing local session when refresh fails.
    }
  }
}
