import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EventService {
  // URL base da API - atualize com o endereço correto do seu backend
  static const String _baseUrl = 'http://172.171.192.14:8081/unieventos';

  // Headers padrão para as requisições
  static final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Método para criar um novo evento
  static Future<Map<String, dynamic>> criarEvento({
    required String nomeEvento,
    required String descricao,
    required String dateInicio,
    required String dateFim,
    required String categoria,
    String? categoriaId,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/eventos');
      final storage = FlutterSecureStorage();
      final token = await storage.read(key: 'token');
      final headers = {
        ..._headers,
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };
      
      // Logs de depuração
      print('[EventService] POST $url');
      print('[EventService] Headers: {Content-Type: ${headers['Content-Type']}, Accept: ${headers['Accept']}, Authorization: ${headers.containsKey('Authorization') ? 'Bearer <redacted>' : 'absent'}}');
      print('[EventService] Body: ' + jsonEncode({
        'nomeEvento': nomeEvento,
        'descricao': descricao,
        'dateInicio': dateInicio,
        'dateFim': dateFim,
        'categoria': categoria,
        if (categoriaId != null && categoriaId.isNotEmpty) 'categoriaId': categoriaId,
      }));
      
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({
          'nomeEvento': nomeEvento,
          'descricao': descricao,
          'dateInicio': dateInicio,
          'dateFim': dateFim,
          'categoria': categoria,
          if (categoriaId != null && categoriaId.isNotEmpty) 'categoriaId': categoriaId,
        }),
      );

      final String responseText = utf8.decode(response.bodyBytes);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': responseText.isNotEmpty ? jsonDecode(responseText) : null,
        };
      } else {
        print('[EventService] Erro ${response.statusCode}: $responseText');
        print('[EventService] Response headers: ${response.headers}');
        return {
          'success': false,
          'error': 'Erro ao criar evento: ${response.statusCode}',
          'details': responseText,
          'message': responseText.isNotEmpty ? responseText : 'Erro ${response.statusCode} sem corpo',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erro de conexão: $e',
      };
    }
  }
}