import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/user_model.dart';
import 'api_config.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  // Fazer Login
  Future<UserModel> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/login'),
      headers: ApiConfig.headers(),
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'] as String;
      final user = UserModel.fromJson(data['user']);

      await _storage.write(key: _tokenKey, value: token);
      await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));

      return user;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Falha ao realizar login.');
    }
  }

  // Obter Token Guardado
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Obter Utilizador Guardado Localmente
  Future<UserModel?> getSavedUser() async {
    final userStr = await _storage.read(key: _userKey);
    if (userStr != null) {
      return UserModel.fromJson(jsonDecode(userStr));
    }
    return null;
  }

  // Fazer Logout
  Future<void> logout() async {
    final token = await getToken();
    if (token != null) {
      try {
        await http.post(
          Uri.parse('${ApiConfig.baseUrl}/logout'),
          headers: ApiConfig.headers(token),
        );
      } catch (_) {}
    }
    await _storage.deleteAll();
  }
}
