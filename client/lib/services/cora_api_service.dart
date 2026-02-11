import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/app_user.dart';

class CoraApiService {
  CoraApiService({this.baseUrl = 'http://10.0.2.2:8080'});

  final String baseUrl;

  Future<AppUser> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
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
      Uri.parse('$baseUrl/signup'),
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
    final response = await http.get(Uri.parse('$baseUrl/friendcode/$code'));
    if (response.statusCode != 200) {
      throw Exception('Friend code not found');
    }
    return (jsonDecode(response.body) as Map<String, dynamic>)['matrix_user_id'] as String;
  }
}
