import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/app_user.dart';
import 'api_config.dart';

class CoraApiService {
  String get _baseUrl => ApiConfig.instance.baseUrl;

  Future<AppUser> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode != 200) {
      throw Exception('Login failed');
    }
    return AppUser.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<AppUser> signup(String email, String password, String displayName) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'display_name': displayName,
      }),
    );
    if (response.statusCode != 201) {
      throw Exception('Signup failed: ${response.body}');
    }
    return AppUser.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<String> resolveFriendCode(String code) async {
    final response = await http.get(Uri.parse('$_baseUrl/friendcode/$code'));
    if (response.statusCode != 200) {
      throw Exception('Friend code not found');
    }
    return (jsonDecode(response.body) as Map<String, dynamic>)['matrix_user_id'] as String;
  }

  Future<void> createFriendRequest({required String fromMatrixUserId, required String toMatrixUserId}) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/friend-requests'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'from_matrix_user_id': fromMatrixUserId,
        'to_matrix_user_id': toMatrixUserId,
      }),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to send friend request');
    }
  }
}
