import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserService {
  static Future<String?> buscarUsuario() async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');

    final url = Uri.parse('http://172.171.192.14:8080/unieventos/usuarios/me');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      await storage.write(key: 'id', value: body['user']['id']);
      await storage.write(key: 'nome', value: body['user']['nome']);
      await storage.write(key: 'sobrenome', value: body['user']['sobrenome']);
      await storage.write(key: 'email', value: body['user']['email']);
      await storage.write(key: 'cursoId', value: body['user']['cursoId']);
      await storage.write(key: 'role', value: body['user']['role']);
      return body['user']['id'];
    } else {
      print('Erro: ${response.statusCode}');
      print('Mensagem: ${response.body}');
      return null;
    }
  }
}