import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/app_user.dart';
import 'api_config.dart';

class FriendRequestItem {
  FriendRequestItem({
    required this.id,
    required this.fromMatrixUserId,
    required this.toMatrixUserId,
    required this.status,
    required this.createdAt,
  });

  final int id;
  final String fromMatrixUserId;
  final String toMatrixUserId;
  final String status;
  final String createdAt;

  factory FriendRequestItem.fromJson(Map<String, dynamic> json) => FriendRequestItem(
        id: json['id'] as int,
        fromMatrixUserId: json['from_matrix_user_id'] as String,
        toMatrixUserId: json['to_matrix_user_id'] as String,
        status: json['status'] as String,
        createdAt: json['created_at'] as String? ?? '',
      );
}

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

  Future<AppUser> me(String email) async {
    final response = await http.get(Uri.parse('$_baseUrl/me/$email'));
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch profile');
    }
    return AppUser.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<AppUser> updateProfile({
    required String email,
    required String displayName,
    required String bio,
    String? avatarUrl,
  }) async {
    final response = await http.patch(
      Uri.parse('$_baseUrl/profile/$email'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'display_name': displayName,
        'bio': bio,
        'avatar_url': avatarUrl,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update profile');
    }
    return AppUser.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<String> uploadAvatar(File file) async {
    final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/upload/avatar'));
    request.files.add(await http.MultipartFile.fromPath('file', file.path));
    final stream = await request.send();
    final response = await http.Response.fromStream(stream);
    if (response.statusCode != 201) {
      throw Exception('Avatar upload failed');
    }
    return (jsonDecode(response.body) as Map<String, dynamic>)['avatar_url'] as String;
  }

  Future<String> resolveFriendCode(String code) async {
    final response = await http.get(Uri.parse('$_baseUrl/friendcode/$code'));
    if (response.statusCode != 200) {
      throw Exception('Friend code not found');
    }
    return (jsonDecode(response.body) as Map<String, dynamic>)['matrix_user_id'] as String;
  }

  Future<void> createFriendRequest({
    required String fromMatrixUserId,
    required String toMatrixUserId,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/friend-requests'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'from_matrix_user_id': fromMatrixUserId,
        'to_matrix_user_id': toMatrixUserId,
      }),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to send friend request: ${response.body}');
    }
  }

  Future<List<FriendRequestItem>> listFriendRequests(String matrixUserId) async {
    final response = await http.get(Uri.parse('$_baseUrl/friend-requests/$matrixUserId'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load friend requests');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final requests = body['requests'] as List<dynamic>;
    return requests
        .map((entry) => FriendRequestItem.fromJson(entry as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateFriendRequest({required int requestId, required String status}) async {
    final response = await http.patch(
      Uri.parse('$_baseUrl/friend-requests/$requestId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': status}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update request');
    }
  }
}
