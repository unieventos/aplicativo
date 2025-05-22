import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'login.dart'; // importa a sua tela de login
import 'eventRegister.dart';
import 'register.dart';
import 'modifyUser.dart';
import 'home.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'perfil.dart';

void main() {
  runApp(MaterialApp(
    home: CadastroUsuarioPage(),
  ));
}

class Usuario {
  final String id;
  final String nome;
  final String sobrenome;
  final String email;
  final int cursoId;
  bool expandido;

  Usuario({
    required this.id,
    required this.nome,
    required this.sobrenome,
    required this.email,
    required this.cursoId,
    this.expandido = false,
  });
}

class CadastroUsuarioPage extends StatefulWidget {
  @override
  _CadastroUsuarioPageState createState() => _CadastroUsuarioPageState();
}

class _CadastroUsuarioPageState extends State<CadastroUsuarioPage> {
  final bool isAdmin = true; // Altere para false se quiser simular usuário comum
  static const _pageSize = 10;
  final PagingController<int, Usuario> _pagingController = PagingController(firstPageKey: 0);
  int _selectedIndex = 2; // índice de Admin alterado para 2
  String _searchText = '';


  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = await UsuarioApi.fetchUsuarios(pageKey, _pageSize, _searchText);
      final isLastPage = newItems.length < _pageSize;

      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar usuários: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Gerenciador de Usuarios",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Pesquisar usuário',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                  _pagingController.refresh();
                });
              },
            ),
          ),
          Expanded(
            child: PagedListView<int, Usuario>(
              pagingController: _pagingController,
              builderDelegate: PagedChildBuilderDelegate<Usuario>(
                itemBuilder: (context, usuario, index) {
                  final isLastItem = index == _pagingController.itemList!.length - 1;
                  return Column(
                    children: [
                      Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Column(
                          children: [
                            ListTile(
                              leading: const CircleAvatar(child: Icon(Icons.person)),
                              title: Text(usuario.nome + ' ' + usuario.sobrenome),
                              subtitle: Text(usuario.email),
                              trailing: IconButton(
                                icon: Icon(
                                  usuario.expandido
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                ),
                                onPressed: () {
                                  setState(() {
                                    usuario.expandido = !usuario.expandido;
                                  });
                                },
                              ),
                            ),
                            if (usuario.expandido)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(builder: (context) => ModifyUserApp()),
                                        );
                                      },
                                      icon: const Icon(Icons.edit, color: Colors.red),
                                      label: const Text("Modificar", style: TextStyle(color: Colors.red)),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        _pagingController.refresh();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      icon: const Icon(Icons.delete, color: Colors.white),
                                      label: const Text("Deletar", style: TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (isLastItem) const SizedBox(height: 80),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == _selectedIndex) return;

          if (index == 0) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => EventosApp()));
          } else if (index == 1) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => EVRegister()));
          } else if (index == 2) {
            // já está na tela CadastroUsuarioPage
            return;
          } else if (index == 3) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PerfilPage()));
          }

          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.feed,
              color: _selectedIndex == 0 ? Colors.black : Colors.grey,
              size: _selectedIndex == 0 ? 28 : 24,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.add,
              color: _selectedIndex == 1 ? Colors.black : Colors.grey,
              size: _selectedIndex == 1 ? 28 : 24,
            ),
            label: '',
          ),
          if (isAdmin)
            BottomNavigationBarItem(
              icon: Icon(
                Icons.admin_panel_settings,
                color: _selectedIndex == 2 ? Colors.black : Colors.grey,
                size: _selectedIndex == 2 ? 28 : 24,
              ),
              label: '',
            ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              color: _selectedIndex == 3 ? Colors.black : Colors.grey,
              size: _selectedIndex == 3 ? 28 : 24,
            ),
            label: '',
          ),
        ],
      ),
      floatingActionButton: MediaQuery.of(context).viewInsets.bottom == 0
          ? Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterScreen(role: 'admin')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text(
                  "Novo Usuário",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}


class UsuarioApi {
  static const String baseUrl = 'http://172.171.192.14:8080/unieventos/usuarios';

  static Future<List<Usuario>> fetchUsuarios(int page, int pageSize, String search) async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');

    if (token == null) {
      throw Exception('Token não encontrado. Usuário não autenticado.');
    }

    final url = Uri.parse('$baseUrl?page=$page&size=$pageSize&sortBy=nome&name=$search');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(utf8.decode(response.bodyBytes));
      final List<dynamic> usuarioList = jsonData['_embedded']?['usuarioResourceV1List'] ?? [];

      return usuarioList.map((jsonItem) {
        final userJson = jsonItem['user'] as Map<String, dynamic>;
        return UsuarioFactory.fromJson(userJson);
      }).toList();
    } else {
      throw Exception('Erro ao carregar usuários: ${response.statusCode}');
    }
  }
}

extension UsuarioFactory on Usuario {
  static Usuario fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] ?? '',
      nome: json['nome'] ?? '',
      sobrenome: json['sobrenome'] ?? '',
      email: json['email'] ?? '',
      cursoId: json['cursoId'] ?? 0,
    );
  }
}