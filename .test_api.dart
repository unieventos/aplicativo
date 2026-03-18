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
  
  final usuariosUrl = Uri.parse('http://172.171.192.14:8081/unieventos/usuarios?page=0&size=1');
  final respUsers = await http.get(usuariosUrl, headers: {'Authorization': 'Bearer $token'});
  print("Users JSON: ${respUsers.body}");
}
