import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import '../api/http_client.dart';

class AuthService {
  AuthService({http.Client? client}) : _client = HttpClientService();

  final HttpClientService _client;

  Future<bool> signIn({
    required String cred,
    required String password,
    required String type,
  }) async {
    await _client.init();
    final response = await _client.post(
      '/auth/signin',
      body: jsonEncode({'cred': cred, 'password': password, 'type': type}),
    );
    if (response.statusCode == 200) return true;
    throw http.ClientException('Signin failed', response.request?.url);
  }

  Future<bool> googleLogin({String? idToken, String? accessToken}) async {
    await _client.init();
    final Map<String, dynamic> body = {};
    if (accessToken != null && accessToken.isNotEmpty) {
      body['accessToken'] = accessToken;
    }

    if (body.isEmpty) {
      throw ArgumentError('Missing Google token');
    }

    log(
      'Google login with body: $body',
      name: 'AuthService.googleLogin',
    ); // Debug log
    final response = await _client.post(
      '/auth/google',
      body: jsonEncode(body),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) return true;
    final String details = response.body.isEmpty ? '' : ': ${response.body}';
    throw http.ClientException(
      'Google login failed (${response.statusCode})$details',
      response.request?.url,
    );
  }

  Future<Map<String, dynamic>?> currentUser() async {
    await _client.init();
    final response = await _client.get('/user');
    if (response.statusCode == 200) {
      if (response.body.isEmpty) return null;
      final dynamic data = jsonDecode(response.body);
      if (data == null) return null;
      if (data is Map<String, dynamic>) return data;
      return Map<String, dynamic>.from(data);
    }
    throw http.ClientException('Fetch user failed', response.request?.url);
  }

  Future<bool> logout() async {
    await _client.init();
    final response = await _client.post('/logout');
    if (response.statusCode == 200) {
      await _client.clearCookies();
      return true;
    }
    throw http.ClientException('Logout failed', response.request?.url);
  }

  Future<String> updateProfile(Map<String, dynamic> payload) async {
    await _client.init();
    final response = await _client.post(
      '/auth/profile',
      body: jsonEncode(payload),
    );
    if (response.statusCode == 200) {
      return response.body.isEmpty ? 'OK' : response.body;
    }
    throw http.ClientException('Update profile failed', response.request?.url);
  }

  Future<bool> updateProfileZod(Map<String, dynamic> payload) async {
    await _client.init();
    final response = await _client.post(
      '/auth/update',
      body: jsonEncode(payload),
    );
    if (response.statusCode == 200) return true;
    throw http.ClientException(
      'Update profile (zod) failed',
      response.request?.url,
    );
  }

  Future<String> requestProfilePicUpload({
    required String fileName,
    int? fileSize,
    String? fileType,
  }) async {
    await _client.init();
    final response = await _client.post(
      '/auth/update_pic',
      body: jsonEncode({
        'fileName': fileName,
        if (fileSize != null) 'fileSize': fileSize,
        if (fileType != null) 'fileType': fileType,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['uploadUrl'] as String;
    }
    throw http.ClientException(
      'Request pic upload failed',
      response.request?.url,
    );
  }
}
