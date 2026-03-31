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
  
  // Create Category
  final catUrl = Uri.parse('http://172.171.192.14:8081/unieventos/categorias');
  final payload = {
    "nomeCategoria": "Teste ${DateTime.now().millisecondsSinceEpoch}"
  };
  
  final respCat = await http.post(
    catUrl, 
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    body: jsonEncode(payload)
  );
  print("POST /categorias Status: ${respCat.statusCode}");
  print("POST /categorias Headers: ${respCat.headers}");
  print("POST /categorias Body: ${respCat.body}");

  // Wait 1 second
  await Future.delayed(Duration(seconds: 1));

  // Fetch Categories
  final fetchUrl = Uri.parse('http://172.171.192.14:8081/unieventos/categorias?size=100');
  final respFetch = await http.get(
    fetchUrl, 
    headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    }
  );
  print("GET /categorias Status: ${respFetch.statusCode}");
  print("GET /categorias size: ${jsonDecode(respFetch.body)['_embedded']?['categoriaResourceV1List']?.length}");
  
  // Let's print the last one
  final list = jsonDecode(respFetch.body)['_embedded']?['categoriaResourceV1List'] as List;
  if (list != null && list.isNotEmpty) {
     print("Last element in fetch: ${list.last}");
     print("Are any elements matching our payload? ${list.any((e) => (e['categoria']?['nomeCategoria'] ?? '') == payload['nomeCategoria'])}");
  }
}
