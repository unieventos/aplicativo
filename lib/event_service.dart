import 'dart:convert';
import 'package:http/http.dart' as http;

class EventService {
  // URL base da API - atualize com o endereço correto do seu backend
  static const String _baseUrl = 'http://172.171.192.14:8080/unieventos';

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
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/evento');
      
      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode({
          'nomeEvento': nomeEvento,
          'descricao': descricao,
          'dateInicio': dateInicio,
          'dateFim': dateFim,
          'categoria': categoria,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'error': 'Erro ao criar evento: ${response.statusCode}',
          'details': response.body,
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