import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_application_1/login.dart';
import 'package:flutter_application_1/models/user_profile.dart';
import 'package:flutter_application_1/user_service.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  _PerfilPageState createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
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
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              "Sair",
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
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
        title: const Text('Meu perfil'),
        automaticallyImplyLeading: false,
        centerTitle: false,
      ),
      body: SafeArea(
        child: FutureBuilder<UserProfile>(
          future: _perfilUsuarioFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Erro ao carregar dados.'));
            }
            if (!snapshot.hasData) {
              return const Center(child: Text('Nenhum dado encontrado.'));
            }

            final perfil = snapshot.data!;

            return RefreshIndicator(
              onRefresh: () async {
                final future = _loadUserData();
                setState(() {
                  _perfilUsuarioFuture = future;
                });
                await future;
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                children: [
                  _buildHeader(perfil),
                  const SizedBox(height: 24),
                  _buildInfoCard(perfil),
                  const SizedBox(height: 24),
                  _buildActionsCard(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(UserProfile perfil) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              child: Text(
                perfil.initials,
                style: TextStyle(
                  fontSize: 40,
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              perfil.fullName.isNotEmpty ? perfil.fullName : 'Usuário',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              perfil.email.isNotEmpty ? perfil.email : 'email@nao.informado',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(UserProfile perfil) {
    final theme = Theme.of(context);
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.school_outlined,
              color: theme.colorScheme.primary,
            ),
            title: const Text('Curso'),
            subtitle: Text(
              perfil.cursoId.isNotEmpty
                  ? 'Curso ID: ${perfil.cursoId}'
                  : 'Não informado',
            ),
          ),
          const Divider(indent: 16, endIndent: 16),
          ListTile(
            leading: Icon(
              Icons.admin_panel_settings_outlined,
              color: theme.colorScheme.primary,
            ),
            title: const Text('Nível de acesso'),
            subtitle: Text(
              perfil.role.isNotEmpty ? perfil.role.toUpperCase() : 'USER',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsCard() {
    final theme = Theme.of(context);
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.edit_outlined, color: theme.colorScheme.primary),
            title: const Text('Editar perfil'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          const Divider(indent: 16, endIndent: 16),
          ListTile(
            leading: Icon(Icons.logout, color: theme.colorScheme.primary),
            title: Text(
              'Sair',
              style: TextStyle(color: theme.colorScheme.primary),
            ),
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}
