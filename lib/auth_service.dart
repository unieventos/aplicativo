import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static Future<String?> fazerLogin(String login, String password, bool stayLogged) async {
    final response = await http.post(
      Uri.parse('http://172.171.192.14:8080/unieventos/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'login': login, 'password': password, 'stayLogged': stayLogged}),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['token']; // ou 'access_token', dependendo da API
    } else {
      print('Erro: ${response.statusCode}');
      print('Mensagem: ${response.body}');
      return null;
    }
  }
}