import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/app_user.dart';
codex/build-cora-cross-platform-chat-app-ulpmvz
import 'api_config.dart';

class CoraApiService {
  String get _baseUrl => ApiConfig.instance.baseUrl;

  Future<AppUser> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),

class CoraApiService {
  CoraApiService({this.baseUrl = 'http://10.0.2.2:8080'});

  final String baseUrl;

  Future<AppUser> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
 main
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
codex/build-cora-cross-platform-chat-app-ulpmvz
      Uri.parse('$_baseUrl/signup'),

      Uri.parse('$baseUrl/signup'),
main
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
codex/build-cora-cross-platform-chat-app-ulpmvz
    final response = await http.get(Uri.parse('$_baseUrl/friendcode/$code'));

    final response = await http.get(Uri.parse('$baseUrl/friendcode/$code'));
 main
    if (response.statusCode != 200) {
      throw Exception('Friend code not found');
    }
    return (jsonDecode(response.body) as Map<String, dynamic>)['matrix_user_id'] as String;
  }
codex/build-cora-cross-platform-chat-app-ulpmvz

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

main
}
