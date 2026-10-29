import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/user_model.dart';
import 'api_config.dart';

class AuthService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  /// Guarda o token JWT/Sanctum de forma segura
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Recupera o token guardado
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Guarda os dados do utilizador localmente
  Future<void> saveUser(UserModel user) async {
    final userJson = jsonEncode(user.toJson());
    await _storage.write(key: _userKey, value: userJson);
  }

  /// Recupera o utilizador guardado
  Future<UserModel?> getSavedUser() async {
    final userString = await _storage.read(key: _userKey);
    if (userString == null) return null;
    try {
      final Map<String, dynamic> userMap = jsonDecode(userString);
      return UserModel.fromJson(userMap);
    } catch (_) {
      return null;
    }
  }

  /// Realiza o login na API do Laravel
  Future<UserModel> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(ApiConfig.loginUrl),
      headers: ApiConfig.headers(),
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      final token = data['token'] ?? data['access_token'];
      final userData = data['user'] ?? data;

      if (token != null) {
        await saveToken(token.toString());
      }

      final user = UserModel.fromJson(userData as Map<String, dynamic>);
      await saveUser(user);

      return user;
    } else {
      // Tenta ler o erro como JSON, senão devolve a mensagem textual limpa
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Falha ao realizar login.');
      } catch (_) {
        throw Exception(
          'Erro no servidor Laravel (${response.statusCode}). Verifique os logs.',
        );
      }
    }
  }

  /// Termina a sessão e limpa os dados armazenados
  Future<void> logout() async {
    final token = await getToken();

    if (token != null) {
      try {
        await http.post(
          Uri.parse(ApiConfig.logoutUrl),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        );
      } catch (_) {
        // Continua a limpeza local mesmo se a chamada de rede falhar
      }
    }

    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }

  /// Verifica se existe uma sessão ativa
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
