import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/usuario.dart'; // Modelo Usuario centralizado
import 'package:flutter_application_1/api_service.dart'; // Importa a sua classe de API

import 'package:flutter_application_1/models/course_option.dart';
import 'package:flutter_application_1/user_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ModifyUserApp extends StatefulWidget {
  final Usuario usuario;

  const ModifyUserApp({Key? key, required this.usuario}) : super(key: key);

  @override
  _ModifyUserAppState createState() => _ModifyUserAppState();
}

class _ModifyUserAppState extends State<ModifyUserApp> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nomeController;
  late TextEditingController _sobrenomeController;
  late TextEditingController _emailController;
  late TextEditingController _loginController;
  late TextEditingController _senhaController;
  
  bool _isAdmin = false;
  bool _isEditingSelf = false;

  bool _isLoadingCursos = false;
  List<CourseOption> _cursos = const [];
  String? _cursoSelecionadoId;
  String? _roleSelecionado;
  bool _isLoading = false;
  bool _obscureText = true;

  static const List<Map<String, String>> _rolesDisponiveis = [
    {'value': 'ADMIN', 'label': 'Administrador'},
    {'value': 'GESTOR', 'label': 'Gestor'},
    {'value': 'COLABORADOR', 'label': 'Colaborador'},
  ];

  late List<Map<String, String>> _rolesDisponiveisList;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.usuario.nome);
    _sobrenomeController = TextEditingController(text: widget.usuario.sobrenome);
    _emailController = TextEditingController(text: widget.usuario.email);
    _loginController = TextEditingController(text: widget.usuario.login);
    _senhaController = TextEditingController();
    final userRole = widget.usuario.role.toUpperCase();
    _rolesDisponiveisList = List.from(_rolesDisponiveis);
    if (userRole.isNotEmpty) {
      if (_rolesDisponiveisList.any((r) => r['value'] == userRole)) {
        _roleSelecionado = userRole;
      } else {
        _rolesDisponiveisList.add({'value': userRole, 'label': userRole});
        _roleSelecionado = userRole;
      }
    } else {
      _roleSelecionado = null;
    }    
    _carregarCursos();
    _verificarPermissao();
  }

  Future<void> _verificarPermissao() async {
    const storage = FlutterSecureStorage();
    final role = await storage.read(key: 'role');
    final myId = await storage.read(key: 'id');
    if (mounted) {
      setState(() {
        _isAdmin = (role?.toUpperCase() == 'ADMIN');
        _isEditingSelf = (myId == widget.usuario.id);
      });
    }
  }

  Future<void> _carregarCursos() async {
    setState(() => _isLoadingCursos = true);
    try {
      final cursos = await UsuarioApi.listarCursos();
      if (!mounted) return;
      setState(() {
        _cursos = cursos;
        _cursoSelecionadoId = null;

        if (widget.usuario.curso.isNotEmpty) {
          final match = _cursos.firstWhere(
            (curso) => curso.nome.toLowerCase() == widget.usuario.curso.toLowerCase(),
            orElse: () => CourseOption(id: '', nome: ''),
          );
          if (match.id.isNotEmpty) {
            _cursoSelecionadoId = match.id;
          }
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao carregar cursos: $e'))
      );
    } finally {
      if (mounted) {
        setState(() => _isLoadingCursos = false);
      }
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _sobrenomeController.dispose();
    _emailController.dispose();
    _loginController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _salvarAlteracoes() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final payload = <String, dynamic>{
      'nome': _nomeController.text.trim(),
      'sobrenome': _sobrenomeController.text.trim(),
      'email': _emailController.text.trim(),
      'login': _loginController.text.trim(),
    };

    if (_isAdmin && !_isEditingSelf) {
      if (_roleSelecionado != null) {
        payload['role'] = _roleSelecionado;
      } else if (widget.usuario.role.isNotEmpty) {
        payload['role'] = widget.usuario.role;
      }
    }

    if (_cursoSelecionadoId != null && _cursoSelecionadoId!.isNotEmpty) {
      try {
        final cursoSelecionado = _cursos.firstWhere(
          (curso) => curso.id == _cursoSelecionadoId,
        );
        payload['curso'] = cursoSelecionado.nome;
      } catch (_) {
        if (widget.usuario.curso.isNotEmpty) {
          payload['curso'] = widget.usuario.curso;
        }
      }
    }

    if (_senhaController.text.isNotEmpty) {
      payload['senha'] = _senhaController.text;
    }

    try {
      final sucesso = await UsuarioApi.atualizarUsuario(
        widget.usuario.id,
        payload,
      );
      if (!mounted) return;

      if (sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário atualizado com sucesso!')),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao atualizar usuário.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar usuário: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildCursoDropdown() {
    if (_isLoadingCursos) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          color: Colors.grey.shade50,
        ),
        child: Row(
          children: const [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Carregando cursos...'),
          ],
        ),
      );
    }

    return DropdownButtonFormField<String>(
      value: _cursoSelecionadoId,
      decoration: const InputDecoration(
        labelText: 'Curso (opcional)',
        prefixIcon: Icon(Icons.school_outlined),
        helperText: 'Deixe sem seleção para manter o curso atual',
      ),
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('Manter curso atual'),
        ),
        ..._cursos.map(
          (curso) => DropdownMenuItem(value: curso.id, child: Text(curso.nome)),
        ),
      ],
      onChanged: (value) => setState(() => _cursoSelecionadoId = value),
    );
  }

  Widget _buildRoleDropdown() {
    return DropdownButtonFormField<String>(
      value: _roleSelecionado,
      decoration: const InputDecoration(
        labelText: 'Perfil de acesso (opcional)',
        prefixIcon: Icon(Icons.admin_panel_settings_outlined),
        helperText: 'Deixe sem alteração para manter o perfil atual',
      ),
      isExpanded: true,
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('Manter perfil atual'),
        ),
        ..._rolesDisponiveisList.map(
          (role) => DropdownMenuItem(
            value: role['value'],
            child: Text(role['label']!),
          ),
        ),
      ],
      onChanged: (value) {
        setState(() => _roleSelecionado = value);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modificar usuário')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Form(
            key: _formKey,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: Text(
                            widget.usuario.initials,
                            style: const TextStyle(
                              fontSize: 28,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Editando ${widget.usuario.displayName}',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'ID: ${widget.usuario.id}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nomeController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Nome',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nome é obrigatório';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _sobrenomeController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Sobrenome',
                        prefixIcon: Icon(Icons.person_2_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Sobrenome é obrigatório';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _loginController,
                      decoration: const InputDecoration(
                        labelText: 'Login',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'O login não pode ser vazio';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        prefixIcon: Icon(Icons.alternate_email),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'E-mail é obrigatório';
                        }
                        if (!value.contains('@')) {
                          return 'E-mail inválido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildCursoDropdown(),
                    const SizedBox(height: 16),
                    if (_isAdmin && !_isEditingSelf) ...[
                      _buildRoleDropdown(),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      controller: _senhaController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        labelText: 'Nova senha (opcional)',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () => setState(() => _obscureText = !_obscureText),
                        ),
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty && value.length < 6) {
                          return 'Senha deve ter pelo menos 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _salvarAlteracoes,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(
                        _isLoading ? 'Salvando...' : 'Salvar alterações',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
