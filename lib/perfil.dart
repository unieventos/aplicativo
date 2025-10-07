import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_application_1/login.dart';
import 'package:flutter_application_1/models/user_profile.dart';
import 'package:flutter_application_1/user_service.dart';

class PerfilPage extends StatefulWidget {
  @override
  _PerfilPageState createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final _storage = FlutterSecureStorage();
  late Future<UserProfile> _perfilUsuarioFuture;

  @override
  void initState() {
    super.initState();
    _perfilUsuarioFuture = _loadUserData();
  }

  Future<UserProfile> _loadUserData() async {
    final profile = await UserService.obterPerfil(persistLocally: true);
    if (profile != null) {
      return profile;
    }

    final cached = await _loadCachedProfile();
    if (cached != null) {
      return cached;
    }

    return const UserProfile(nome: 'Usuário');
  }

  Future<UserProfile?> _loadCachedProfile() async {
    final values = await Future.wait([
      _storage.read(key: 'id'),
      _storage.read(key: 'nome'),
      _storage.read(key: 'sobrenome'),
      _storage.read(key: 'email'),
      _storage.read(key: 'cursoId'),
      _storage.read(key: 'role'),
    ]);

    if (values.every((value) => value == null || value.isEmpty)) {
      return null;
    }

    return UserProfile(
      id: values[0] ?? '',
      nome: values[1] ?? '',
      sobrenome: values[2] ?? '',
      email: values[3] ?? '',
      cursoId: values[4] ?? '',
      role: values[5] ?? 'user',
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
      body: FutureBuilder<UserProfile>(
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
              final future = _loadUserData();
              setState(() { _perfilUsuarioFuture = future; });
              await future;
            },
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildHeader(perfil),
                SizedBox(height: 24),
                _buildInfoCard(perfil),
                SizedBox(height: 24),
                _buildActionsCard(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(UserProfile perfil) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Text(
            perfil.initials,
            style: TextStyle(fontSize: 48, color: Theme.of(context).primaryColor),
          ),
        ),
        SizedBox(height: 12),
        Text(
          perfil.fullName.isNotEmpty ? perfil.fullName : 'Usuário',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        Text(
          perfil.email.isNotEmpty ? perfil.email : 'email@nao.informado',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildInfoCard(UserProfile perfil) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.school_outlined, color: Theme.of(context).primaryColor),
              title: Text("Curso"),
              subtitle: Text(
                perfil.cursoId.isNotEmpty ? 'Curso ID: ${perfil.cursoId}' : 'Não informado',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
            Divider(indent: 16, endIndent: 16),
            ListTile(
              leading: Icon(Icons.admin_panel_settings_outlined, color: Theme.of(context).primaryColor),
              title: Text("Nível de Acesso"),
              subtitle: Text(
                perfil.role.isNotEmpty ? perfil.role.toUpperCase() : 'USER',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActionsCard() {
    return Card(
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
       child: Column(
         children: [
            ListTile(
              leading: Icon(Icons.edit_outlined, color: Colors.blue.shade700),
              title: Text("Editar Perfil"),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () { /* Navegar para a tela de edição */ },
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
