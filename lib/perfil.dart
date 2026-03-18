import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_application_1/login.dart';
import 'package:flutter_application_1/modifyUser.dart';
import 'package:flutter_application_1/models/usuario.dart';

class PerfilUsuario {
  final String id, nome, sobrenome, email, curso, role, login;
  final int cursoId;
  PerfilUsuario({
    this.id = '',
    this.nome = '',
    this.sobrenome = '',
    this.email = '',
    this.curso = 'Não informado',
    this.role = 'user',
    this.login = '',
    this.cursoId = 0,
  });
}

class PerfilPage extends StatefulWidget {
  @override
  _PerfilPageState createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final _storage = FlutterSecureStorage();
  late Future<PerfilUsuario> _perfilUsuarioFuture;

  @override
  void initState() {
    super.initState();
    _perfilUsuarioFuture = _loadUserData();
  }

  Future<PerfilUsuario> _loadUserData() async {
    final values = await Future.wait([
      _storage.read(key: 'nome'),
      _storage.read(key: 'sobrenome'),
      _storage.read(key: 'email'),
      _storage.read(key: 'cursoId'),
      _storage.read(key: 'role'),
      _storage.read(key: 'id'),
      _storage.read(key: 'login'),
    ]);
    return PerfilUsuario(
      nome: values[0] ?? 'Usuário',
      sobrenome: values[1] ?? '',
      email: values[2] ?? 'email@nao.informado',
      curso: values[3] ?? 'Não informado', // O backend já traz o nome do curso no login!
      role: values[4] ?? 'user',
      id: values[5] ?? '',
      login: values[6] ?? '',
      cursoId: int.tryParse(values[3] ?? '0') ?? 0,
    );
  }

  Future<void> _logout() async {
    bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirmar Logout"),
        content: Text("Tem certeza que deseja sair?"),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text("Cancelar")),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text("Sair", style: TextStyle(color: Theme.of(context).primaryColor)),
          ),
        ],
      ),
    );

    if (confirmar == true && mounted) {
      await _storage.deleteAll();
      // CORREÇÃO: Navega para a LoginScreen e remove todas as outras telas da pilha.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Meu Perfil"),
        automaticallyImplyLeading: false,
        centerTitle: false,
      ),
      body: FutureBuilder<PerfilUsuario>(
        future: _perfilUsuarioFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Erro ao carregar dados."));
          }
          if (!snapshot.hasData) {
            return Center(child: Text("Nenhum dado encontrado."));
          }

          final perfil = snapshot.data!;
          
          return RefreshIndicator(
            onRefresh: () async {
              setState(() { _perfilUsuarioFuture = _loadUserData(); });
            },
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildHeader(perfil),
                SizedBox(height: 24),
                _buildInfoCard(perfil),
                SizedBox(height: 24),
                _buildActionsCard(perfil),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(PerfilUsuario perfil) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Text(
            perfil.nome.isNotEmpty ? perfil.nome[0].toUpperCase() : 'U',
            style: TextStyle(fontSize: 48, color: Theme.of(context).primaryColor),
          ),
        ),
        SizedBox(height: 12),
        Text('${perfil.nome} ${perfil.sobrenome}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        Text(perfil.email, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildInfoCard(PerfilUsuario perfil) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.school_outlined, color: Theme.of(context).primaryColor),
              title: Text("Curso"),
              subtitle: Text(perfil.curso, style: TextStyle(fontSize: 16, color: Colors.black87)),
            ),
            Divider(indent: 16, endIndent: 16),
            ListTile(
              leading: Icon(Icons.admin_panel_settings_outlined, color: Theme.of(context).primaryColor),
              title: Text("Nível de Acesso"),
              subtitle: Text(perfil.role.toUpperCase(), style: TextStyle(fontSize: 16, color: Colors.black87)),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActionsCard(PerfilUsuario perfil) {
    return Card(
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
       child: Column(
         children: [
            ListTile(
              leading: Icon(Icons.edit_outlined, color: Colors.blue.shade700),
              title: Text("Editar Perfil"),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                final usuario = Usuario(
                  id: perfil.id,
                  nome: perfil.nome,
                  sobrenome: perfil.sobrenome,
                  email: perfil.email,
                  login: perfil.login,
                  cursoId: perfil.cursoId,
                  cursoNome: perfil.curso, // Novo campo
                );
                final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => ModifyUserApp(usuario: usuario)));
                if (result == true) {
                  setState(() { _perfilUsuarioFuture = _loadUserData(); });
                }
              },
            ),
            Divider(indent: 16, endIndent: 16),
            ListTile(
              leading: Icon(Icons.logout, color: Theme.of(context).primaryColor),
              title: Text("Sair", style: TextStyle(color: Theme.of(context).primaryColor)),
              onTap: _logout,
            ),
         ],
       ),
    );
  }
}