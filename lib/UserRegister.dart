import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Seus imports, garantindo que os nomes das classes estão corretos
import 'package:flutter_application_1/modifyUser.dart'; // Supõe que a classe seja ModifyUserApp
import 'package:flutter_application_1/register.dart'; // Supõe que a classe seja RegisterScreen

// --- MODELO DE DADOS ---
// Otimizado para não precisar de uma variável de estado 'expandido'
class Usuario {
  final String id;
  final String nome;
  final String sobrenome;
  final String email;
  final int cursoId;

  Usuario({
    required this.id,
    required this.nome,
    required this.sobrenome,
    required this.email,
    required this.cursoId,
  });

  // Factory para criar um Usuário a partir de um JSON
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] ?? '',
      nome: json['nome'] ?? '',
      sobrenome: json['sobrenome'] ?? '',
      email: json['email'] ?? '',
      cursoId: json['cursoId'] ?? 0,
    );
  }
}

// --- TELA PRINCIPAL DE GERENCIAMENTO DE USUÁRIOS ---
class CadastroUsuarioPage extends StatefulWidget {
  @override
  _CadastroUsuarioPageState createState() => _CadastroUsuarioPageState();
}

class _CadastroUsuarioPageState extends State<CadastroUsuarioPage> {
  static const _pageSize = 10;
  final PagingController<int, Usuario> _pagingController = PagingController(firstPageKey: 0);
  String _searchText = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  // Função para buscar os dados da API
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
    }
  }

  // Função de busca com "debounce" para não chamar a API a cada letra digitada
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchText = query;
      });
      _pagingController.refresh();
    });
  }

  @override
  void dispose() {
    _pagingController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Esta tela não deve ter o botão de voltar, pois faz parte da navegação principal
        automaticallyImplyLeading: false, 
        title: Text("Gerenciar Usuários"),
        centerTitle: false,
      ),
      // O corpo agora está mais organizado
      body: Column(
        children: [
          // Campo de busca com design moderno
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Pesquisar por nome...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          // Lista paginada
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => Future.sync(() => _pagingController.refresh()),
              child: PagedListView<int, Usuario>(
                pagingController: _pagingController,
                builderDelegate: PagedChildBuilderDelegate<Usuario>(
                  // Widget a ser exibido para cada item da lista
                  itemBuilder: (context, usuario, index) => _UsuarioListItem(
                    usuario: usuario,
                    onDelete: () {
                      // TODO: Adicionar lógica para deletar usuário
                      // Após deletar, chame _pagingController.refresh() para atualizar a lista
                    },
                    onModify: () {
                      // CORREÇÃO: Navega para a tela de modificar
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ModifyUserApp(usuario: usuario)));
                    },
                  ),
                  // Widgets para os diferentes estados da lista (carregando, erro, vazia)
                  firstPageProgressIndicatorBuilder: (_) => Center(child: CircularProgressIndicator()),
                  newPageProgressIndicatorBuilder: (_) => Center(child: CircularProgressIndicator()),
                  noItemsFoundIndicatorBuilder: (_) => Center(child: Text("Nenhum usuário encontrado.")),
                  firstPageErrorIndicatorBuilder: (_) => Center(child: Text("Erro ao carregar usuários.")),
                ),
              ),
            ),
          ),
        ],
      ),
      // Botão flutuante para adicionar novo usuário
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // CORREÇÃO: Navega para a tela de registro
          Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen(role: 'admin')));
        },
        icon: Icon(Icons.add),
        label: Text("Novo Usuário"),
        backgroundColor: Theme.of(context).primaryColor, // Usa a cor do tema
        foregroundColor: Colors.white,
      ),
    );
  }
}

// --- WIDGET PARA O ITEM DA LISTA DE USUÁRIO (CARD) ---
// Separar em um widget menor deixa o código principal mais limpo.
class _UsuarioListItem extends StatelessWidget {
  final Usuario usuario;
  final VoidCallback onDelete;
  final VoidCallback onModify;

  const _UsuarioListItem({
    required this.usuario,
    required this.onDelete,
    required this.onModify,
  });

  @override
  Widget build(BuildContext context) {
    // ExpansionTile é um widget do próprio Flutter que lida com a lógica de expandir/recolher.
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          foregroundColor: Theme.of(context).primaryColor,
          child: Text(usuario.nome.isNotEmpty ? usuario.nome[0].toUpperCase() : '?'),
        ),
        title: Text('${usuario.nome} ${usuario.sobrenome}', style: TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(usuario.email),
        children: [
          // Conteúdo que aparece quando o card é expandido
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Botão de Modificar
                TextButton.icon(
                  onPressed: onModify,
                  icon: Icon(Icons.edit, size: 18),
                  label: Text("Modificar"),
                  style: TextButton.styleFrom(foregroundColor: Colors.blue.shade700),
                ),
                SizedBox(width: 8),
                // Botão de Deletar
                TextButton.icon(
                  onPressed: onDelete,
                  icon: Icon(Icons.delete_outline, size: 18),
                  label: Text("Deletar"),
                  style: TextButton.styleFrom(foregroundColor: Theme.of(context).primaryColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- LÓGICA DA API ---
// Mantida como estava, pois já está bem estruturada.
class UsuarioApi {
  static const String baseUrl = 'http://172.171.192.14:8081/unieventos/usuarios';

  static Future<List<Usuario>> fetchUsuarios(int page, int pageSize, String search) async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');

    if (token == null) {
      throw Exception('Token não encontrado. Usuário não autenticado.');
    }

    final url = Uri.parse('$baseUrl?page=$page&size=$pageSize&sortBy=nome&name=$search');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(utf8.decode(response.bodyBytes));
      // CORREÇÃO: O nome da lista no seu JSON é 'usuarioResourceV1List'
      final List<dynamic> usuarioList = jsonData['_embedded']?['usuarioResourceV1List'] ?? [];

      return usuarioList.map((jsonItem) {
        final userJson = jsonItem['user'] as Map<String, dynamic>;
        return Usuario.fromJson(userJson);
      }).toList();
    } else {
      throw Exception('Erro ao carregar usuários: ${response.statusCode}');
    }
  }
}