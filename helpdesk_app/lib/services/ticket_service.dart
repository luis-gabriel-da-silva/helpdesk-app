import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/ticket_model.dart';
import '../models/ticket_message_model.dart';
import 'api_config.dart';
import 'auth_service.dart';
import '../core/constants/app_strings.dart';

class TicketService {
  final AuthService _authService = AuthService();

  // Listar Chamados
  Future<List<TicketModel>> getTickets() async {
    final token = await _authService.getToken();
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/tickets'),
      headers: ApiConfig.headers(token),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['data'];
      return data.map((item) => TicketModel.fromJson(item)).toList();
    } else {
      throw Exception('Erro ao carregar chamados.');
    }
  }

  // Detalhes de um Chamado
  Future<TicketModel> getTicketById(int id) async {
    final token = await _authService.getToken();
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/tickets/$id'),
      headers: ApiConfig.headers(token),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return TicketModel.fromJson(data);
    } else {
      throw Exception('Erro ao carregar detalhes do chamado.');
    }
  }

  Future<TicketModel> updateTicket({
    required int ticketId,
    required String title,
    required String category,
    required String priority,
    required String description,
  }) async {
    final token = await _authService.getToken();
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/tickets/$ticketId'),
      headers: ApiConfig.headers(token),
      body: jsonEncode({
        'title': title,
        'category': category,
        'priority': priority,
        'description': description,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return TicketModel.fromJson(data);
    }
    throw Exception(_responseError(response, 'Erro ao editar chamado.'));
  }

  Future<void> deleteTicket(int ticketId) async {
    final token = await _authService.getToken();
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/tickets/$ticketId'),
      headers: ApiConfig.headers(token),
    );

    if (response.statusCode == 200 || response.statusCode == 204) return;

    var message = 'Erro ao apagar o chamado.';
    try {
      final error = jsonDecode(response.body);
      if (error is Map<String, dynamic> && error['message'] is String) {
        message = error['message'] as String;
      }
    } catch (_) {}
    throw Exception(message);
  }

  // Criar Novo Chamado (Suporte Híbrido a Anexo: Bytes para Web, FilePath para Mobile)
  Future<TicketModel> createTicket({
    required String title,
    required String category,
    required String description,
    String priority = 'media',
    String? filePath,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    final token = await _authService.getToken();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConfig.baseUrl}/tickets'),
    );

    request.headers.addAll({
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });

    request.fields['title'] = title;
    request.fields['category'] = category;
    request.fields['priority'] = priority;
    request.fields['description'] = description;

    // Tratamento de anexo
    if (kIsWeb && fileBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'attachment',
          fileBytes,
          filename: fileName ?? 'attachment.png',
        ),
      );
    } else if (filePath != null) {
      request.files.add(
        await http.MultipartFile.fromPath('attachment', filePath),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return TicketModel.fromJson(data);
    } else {
      throw Exception(_responseError(response, 'Erro ao criar chamado.'));
    }
  }

  // Adicionar Mensagem a um Chamado (Suporte Híbrido Web/Mobile)
  Future<TicketMessageModel> addMessage(
    int ticketId,
    String message, {
    String? filePath,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    final token = await _authService.getToken();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConfig.baseUrl}/tickets/$ticketId/messages'),
    );

    request.headers.addAll({
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });

    request.fields['message'] = message;

    if (kIsWeb && fileBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'attachment',
          fileBytes,
          filename: fileName ?? 'attachment.png',
        ),
      );
    } else if (filePath != null) {
      request.files.add(
        await http.MultipartFile.fromPath('attachment', filePath),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body)['data'];
      return TicketMessageModel.fromJson(data);
    } else {
      throw Exception(AppStrings.sendMessageError);
    }
  }

  String _responseError(http.Response response, String fallback) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message'];
        if (message is String && message.isNotEmpty) return message;
        final errors = decoded['errors'];
        if (errors is Map<String, dynamic>) {
          for (final value in errors.values) {
            if (value is List && value.isNotEmpty) {
              return value.first.toString();
            }
          }
        }
      }
    } catch (_) {}
    return fallback;
  }

  // Atualizar Status do Chamado
  Future<TicketModel> updateStatus(int ticketId, String status) async {
    final token = await _authService.getToken();
    final response = await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/tickets/$ticketId/status'),
      headers: ApiConfig.headers(token),
      body: jsonEncode({'status': status}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return TicketModel.fromJson(data);
    } else {
      throw Exception(AppStrings.updateStatusError);
    }
  }
}
