import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_application_1/login.dart';
import 'package:flutter_application_1/api/models/usuario_dto_v2.dart';
import 'package:flutter_application_1/services/usuario_service.dart';
import 'package:flutter_application_1/network/safe_http.dart';

class PerfilPage extends StatefulWidget {
  @override
  _PerfilPageState createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final _storage = FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();
  late UsuarioService _usuarioService;
  late Future<UsuarioDTOV2> _perfilUsuarioFuture;
  
  bool _isLoading = false;
  String? _errorMessage;
  
  TextEditingController _nomeController = TextEditingController();
  TextEditingController _sobrenomeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _usuarioService = UsuarioService(SafeHttp());
    _perfilUsuarioFuture = _loadUserData();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _sobrenomeController.dispose();
    super.dispose();
  }

  Future<UsuarioDTOV2> _loadUserData() async {
    try {
      final usuario = await _usuarioService.getProfile();
      _nomeController.text = usuario.nome;
      _sobrenomeController.text = usuario.sobrenome;
      return usuario;
    } catch (e) {
      throw Exception('Falha ao carregar perfil: $e');
    }
  }

  Future<void> _updateProfile(UsuarioDTOV2 currentUser) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final updatedUser = currentUser.copyWith(
        nome: _nomeController.text,
        sobrenome: _sobrenomeController.text,
      );

      await _usuarioService.updateProfile(updatedUser);
      
      if (mounted) {
        setState(() {
          _perfilUsuarioFuture = Future.value(updatedUser);
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Perfil atualizado com sucesso!'))
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Erro ao atualizar perfil: $e';
        });
      }
    }
  }

  Future<void> _uploadProfilePhoto() async {
    try {
      final ImagePicker _picker = ImagePicker();
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      
      if (image == null) return;

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      await _usuarioService.uploadProfilePhoto(File(image.path));
      
      // Reload profile data to get updated photo
      setState(() {
        _perfilUsuarioFuture = _loadUserData();
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Foto atualizada com sucesso!'))
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Erro ao atualizar foto: $e';
        });
      }
    }
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
            child: Text("Cancelar")
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text("Sair", style: TextStyle(color: Theme.of(context).primaryColor)),
          ),
        ],
      ),
    );

    if (confirmar == true && mounted) {
      await _storage.deleteAll();
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
      body: FutureBuilder<UsuarioDTOV2>(
        future: _perfilUsuarioFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Erro ao carregar dados: ${snapshot.error}"));
          }
          if (!snapshot.hasData) {
            return Center(child: Text("Nenhum dado encontrado."));
          }

          final perfil = snapshot.data!;
          
          return RefreshIndicator(
            onRefresh: () async {
              setState(() { _perfilUsuarioFuture = _loadUserData(); });
            },
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildHeader(perfil),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  SizedBox(height: 24),
                  _buildProfileForm(perfil),
                  SizedBox(height: 24),
                  _buildInfoCard(perfil),
                  SizedBox(height: 24),
                  _buildActionsCard(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(UsuarioDTOV2 perfil) {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Text(
                perfil.nome.isNotEmpty ? perfil.nome[0].toUpperCase() : 'U',
                style: TextStyle(fontSize: 48, color: Theme.of(context).primaryColor),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                radius: 18,
                child: IconButton(
                  icon: Icon(Icons.camera_alt, size: 18, color: Colors.white),
                  onPressed: _isLoading ? null : _uploadProfilePhoto,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Text(
          '${perfil.nome} ${perfil.sobrenome}',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
        ),
        SizedBox(height: 4),
        Text(
          perfil.email ?? 'Email não informado',
          style: TextStyle(fontSize: 16, color: Colors.grey[600])
        ),
      ],
    );
  }

  Widget _buildProfileForm(UsuarioDTOV2 perfil) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nomeController,
              decoration: InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira seu nome';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _sobrenomeController,
              decoration: InputDecoration(
                labelText: 'Sobrenome',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira seu sobrenome';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : () => _updateProfile(perfil),
              child: _isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2)
                  )
                : Text('Salvar Alterações'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(UsuarioDTOV2 perfil) {
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
                'Curso ID: ${perfil.cursoId}',
                style: TextStyle(fontSize: 16, color: Colors.black87)
              ),
            ),
            Divider(indent: 16, endIndent: 16),
            ListTile(
              leading: Icon(Icons.admin_panel_settings_outlined, color: Theme.of(context).primaryColor),
              title: Text("Nível de Acesso"),
              subtitle: Text(
                (perfil.role ?? 'user').toUpperCase(),
                style: TextStyle(fontSize: 16, color: Colors.black87)
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
            leading: Icon(Icons.logout, color: Theme.of(context).primaryColor),
            title: Text("Sair", style: TextStyle(color: Theme.of(context).primaryColor)),
            onTap: _isLoading ? null : _logout,
          ),
        ],
      ),
    );
  }
}