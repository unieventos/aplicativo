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
  
  final eventosUrl = Uri.parse('http://172.171.192.14:8081/unieventos/eventos?page=0&size=1');
  
  final respEventos = await http.get(
    eventosUrl, 
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    }
  );
  print("Status: ${respEventos.statusCode}");
  if (respEventos.statusCode == 200) {
    final data = jsonDecode(utf8.decode(respEventos.bodyBytes));
    final list = data['_embedded']?['eventoResourceV1List'] ?? [];
    if (list.isNotEmpty) {
      print("Primeiro evento:");
      print(JsonEncoder.withIndent('  ').convert(list.first['evento']));
    } else {
      print("Nenhum evento retornado");
    }
  } else {
    print("Body: ${respEventos.body}");
  }
}
