import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_application_1/screens/login.dart';
import 'package:flutter_application_1/screens/modify_user.dart';
import 'package:flutter_application_1/models/usuario.dart';
import 'package:flutter_application_1/services/user_service.dart';
import 'package:flutter_application_1/models/user_profile.dart';
import 'package:flutter_application_1/config/app_theme.dart';
import 'package:flutter_application_1/widgets/branded_header.dart';
import 'package:flutter_application_1/widgets/state_views.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  _PerfilPageState createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true));
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
      _storage.read(key: 'id'),
      _storage.read(key: 'login'),
    ]);
    return UserProfile(
      id: values[0] ?? '',
      nome: values[1] ?? 'Usuário',
      sobrenome: values[2] ?? '',
      email: values[3] ?? 'email@nao.informado',
      role: values[5] ?? 'user',
      cursoId: values[4] ?? '0',
      login: values[7] ?? '',
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
      // Navega para a LoginScreen e remove todas as outras telas da pilha.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile>(
      future: _perfilUsuarioFuture,
      builder: (context, snapshot) {
        final perfil = snapshot.data;

        // Avatar/nome/email slot — only shown when data is available
        Widget? headerBottom;
        if (perfil != null) {
          headerBottom = _buildHeaderProfile(perfil);
        }

        return BrandedScaffold(
          header: BrandedHeader(
            title: 'Meu perfil',
            bottom: headerBottom,
          ),
          body: _buildBody(snapshot, perfil),
        );
      },
    );
  }

  Widget _buildBody(AsyncSnapshot<UserProfile> snapshot, UserProfile? perfil) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const LoadingView();
    }
    if (snapshot.hasError) {
      return ErrorView(
        message: 'Erro ao carregar dados.',
        onRetry: () {
          setState(() {
            _perfilUsuarioFuture = _loadUserData();
          });
        },
      );
    }
    if (perfil == null) {
      return const LoadingView();
    }

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _perfilUsuarioFuture = _loadUserData();
        });
      },
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          const SizedBox(height: AppSpacing.md),
          _buildActionsCard(perfil),
        ],
      ),
    );
  }

  /// Avatar + nome + email exibidos dentro da faixa branded do BrandedHeader.
  Widget _buildHeaderProfile(UserProfile perfil) {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.white.withValues(alpha: 0.25),
          child: Text(
            perfil.initials,
            style: const TextStyle(
              fontSize: 22,
              color: AppColors.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                perfil.fullName.isNotEmpty ? perfil.fullName : 'Usuário',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                perfil.email.isNotEmpty
                    ? perfil.email
                    : 'email@nao.informado',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white70,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionsCard(UserProfile perfil) {
    return Card(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      child: Column(
        children: [
          ListTile(
            leading:
                const Icon(Icons.edit_outlined, color: AppColors.primary),
            title: const Text("Editar Perfil"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () async {
              final usuario = Usuario(
                id: perfil.id,
                nome: perfil.nome,
                sobrenome: perfil.sobrenome,
                email: perfil.email,
                login: perfil.login,
                cursoId: int.tryParse(perfil.cursoId) ?? 0,
                cursoNome: 'Não informado',
                role: perfil.role,
              );
              final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ModifyUserApp(usuario: usuario)));
              if (result == true) {
                setState(() {
                  _perfilUsuarioFuture = _loadUserData();
                });
              }
            },
          ),
          const Divider(indent: 16, endIndent: 16),
          ListTile(
            leading: const Icon(Icons.school_outlined, color: AppColors.primary),
            title: const Text('Curso'),
            subtitle: Text(
              perfil.cursoId != '0' && perfil.cursoId.isNotEmpty
                  ? 'Curso ID: ${perfil.cursoId}'
                  : 'Não informado',
            ),
          ),
          const Divider(indent: 16, endIndent: 16),
          ListTile(
            leading: const Icon(
              Icons.admin_panel_settings_outlined,
              color: AppColors.primary,
            ),
            title: const Text('Nível de acesso'),
            subtitle: Text(
              perfil.role.isNotEmpty ? perfil.role.toUpperCase() : 'USER',
            ),
          ),
          const Divider(indent: 16, endIndent: 16),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.primary),
            title: Text(
              'Sair',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}
