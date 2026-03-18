import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final loginUrl = Uri.parse('http://172.171.192.14:8081/unieventos/auth/login');
  final resp = await http.post(loginUrl, headers: {'Content-Type': 'application/json'}, body: jsonEncode({"login":"simp","password":"simp123","stayLogged":false}));
  if (resp.statusCode != 200) {
    print("Login failed: ${resp.statusCode}");
    return;
  }
  final token = jsonDecode(resp.body)['token'];
  
  final usuariosUrl = Uri.parse('http://172.171.192.14:8081/unieventos/usuarios');
  final payload = {
    "curso": "Administração",
    "email": "muriloliro@gmail.com",
    "login": "murilo",
    "nome": "mu",
    "role": "ADMIN",
    "senha": "murilo123",
    "sobrenome": "rilo"
  };
  
  final respUsers = await http.post(
    usuariosUrl, 
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    },
    body: jsonEncode(payload)
  );
  print("Status: ${respUsers.statusCode}");
  print("Body: ${respUsers.body}");
}
