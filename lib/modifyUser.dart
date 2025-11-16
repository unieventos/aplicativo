import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/usuario.dart'; // Modelo Usuario centralizado
import 'package:flutter_application_1/api_service.dart' as api_service;
import 'package:flutter_application_1/models/course_option.dart';
import 'package:flutter_application_1/models/managed_user.dart';
import 'package:flutter_application_1/services/user_management_api.dart';
import 'package:flutter_application_1/user_service.dart';

class ModifyUserApp extends StatefulWidget {
  final Usuario usuario;

  const ModifyUserApp({Key? key, required this.usuario}) : super(key: key);

  @override
  _ModifyUserAppState createState() => _ModifyUserAppState();
}

class _ModifyUserAppState extends State<ModifyUserApp> {
  final _formKey = GlobalKey<FormState>();

  // Controllers para os campos do formulário.
  late TextEditingController _nomeController;
  late TextEditingController _sobrenomeController;
  late TextEditingController _emailController;
  late TextEditingController _loginController;
  late TextEditingController _senhaController;
  bool _isLoadingCursos = false;
  List<CourseOption> _cursos = const [];
  String? _cursoSelecionadoId;
  String? _roleSelecionado;
  bool _isLoading = false;
  bool _obscureText = true;

  // Lista de roles disponíveis
  static const List<Map<String, String>> _rolesDisponiveis = [
    {'value': 'ADMIN', 'label': 'Administrador'},
    {'value': 'GESTOR', 'label': 'Gestor'},
    {'value': 'COLABORADOR', 'label': 'Colaborador'},
  ];

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.usuario.nome);
    _sobrenomeController = TextEditingController(
      text: widget.usuario.sobrenome,
    );
    _emailController = TextEditingController(text: widget.usuario.email);
    _loginController = TextEditingController(text: widget.usuario.login);
    _senhaController = TextEditingController();
    _cursoSelecionadoId = widget.usuario.curso.isNotEmpty
        ? widget.usuario.curso
        : null;
    // Inicializa o role selecionado com o role atual do usuário
    _roleSelecionado = widget.usuario.role.isNotEmpty
        ? widget.usuario.role.toUpperCase()
        : 'COLABORADOR';
    _carregarCursos();
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

  Future<void> _carregarCursos() async {
    setState(() => _isLoadingCursos = true);
    try {
      final cursos = await api_service.UsuarioApi.listarCursos();
      if (!mounted) return;
      setState(() {
        _cursos = cursos;
        if (_cursos.isEmpty) {
          _cursoSelecionadoId = null;
        } else if (_cursoSelecionadoId != null &&
            !_cursos.any((c) => c.id == _cursoSelecionadoId)) {
          _cursoSelecionadoId = null;
        }

        if ((_cursoSelecionadoId == null || _cursoSelecionadoId!.isEmpty) &&
            widget.usuario.curso.isNotEmpty) {
          final match = _cursos.firstWhere(
            (curso) =>
                curso.nome.toLowerCase() == widget.usuario.curso.toLowerCase(),
            orElse: () => CourseOption(id: '', nome: ''),
          );
          if (match.id.isNotEmpty) {
            _cursoSelecionadoId = match.id;
          }
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Falha ao carregar cursos: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoadingCursos = false);
      }
    }
  }

  // Função para lidar com o salvamento das alterações.
  Future<void> _salvarAlteracoes() async {
    // Valida o formulário antes de continuar.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    // Monta o payload apenas com os campos que foram alterados ou que têm valor
    final payload = <String, dynamic>{
      'nome': _nomeController.text.trim(),
      'sobrenome': _sobrenomeController.text.trim(),
      'email': _emailController.text.trim(),
      'role': _roleSelecionado ?? 'COLABORADOR',
    };

    // Adiciona login apenas se foi alterado e não está vazio
    final loginAtualizado = _loginController.text.trim();
    if (loginAtualizado.isNotEmpty && loginAtualizado != widget.usuario.login) {
      payload['login'] = loginAtualizado;
    }

    // Adiciona curso apenas se foi selecionado um curso diferente
    if (_cursoSelecionadoId != null && _cursoSelecionadoId!.isNotEmpty) {
      try {
        final cursoSelecionado = _cursos.firstWhere(
          (curso) => curso.id == _cursoSelecionadoId,
        );
        final nomeCurso = cursoSelecionado.nome;
        // Só adiciona se o curso foi alterado
        if (nomeCurso != widget.usuario.curso) {
          payload['curso'] = nomeCurso; // API espera o nome do curso, não o ID
        }
      } catch (e) {
        // Se o curso não for encontrado na lista, mas foi selecionado, envia o nome original
        if (widget.usuario.curso.isNotEmpty) {
          payload['curso'] = widget.usuario.curso;
        }
      }
    }

    // Adiciona senha apenas se foi preenchida
    if (_senhaController.text.isNotEmpty) {
      payload['senha'] = _senhaController.text;
    }

    try {
      // Usa UserService que tem melhor tratamento de erros e filtragem de campos vazios
      final sucesso = await UserService.atualizarUsuario(
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
      
      // Trata erros de CORS especificamente
      final errorMessage = e.toString().toLowerCase();
      String mensagemErro;
      
      if (errorMessage.contains('cors') || 
          errorMessage.contains('cross-origin') ||
          errorMessage.contains('networkerror') ||
          errorMessage.contains('access-control-allow-methods')) {
        mensagemErro = 'Erro de CORS: O backend precisa permitir o método PATCH nas configurações de CORS. Entre em contato com o administrador do sistema.';
      } else {
        mensagemErro = 'Erro ao atualizar usuário: $e';
      }
      
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(mensagemErro),
          duration: const Duration(seconds: 5),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          child: Text(
                            widget.usuario.nome.isNotEmpty
                                ? widget.usuario.nome[0].toUpperCase()
                                : 'U',
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
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'ID: ${widget.usuario.id}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey[600]),
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
                        labelText: 'Login (opcional)',
                        prefixIcon: Icon(Icons.person_outline),
                        helperText: 'Nome de usuário para login - deixe vazio para manter o atual',
                      ),
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
                    _buildRoleDropdown(),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _senhaController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        labelText: 'Nova senha (opcional)',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () =>
                              setState(() => _obscureText = !_obscureText),
                        ),
                      ),
                      validator: (value) {
                        if (value != null &&
                            value.isNotEmpty &&
                            value.length < 6) {
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
                                valueColor: AlwaysStoppedAnimation(
                                  Colors.white,
                                ),
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
        ..._cursos
            .map(
              (curso) =>
                  DropdownMenuItem(value: curso.id, child: Text(curso.nome)),
            )
            .toList(),
      ],
      onChanged: (value) => setState(() => _cursoSelecionadoId = value),
    );
  }

  Widget _buildRoleDropdown() {
    return DropdownButtonFormField<String>(
      value: _roleSelecionado,
      decoration: const InputDecoration(
        labelText: 'Perfil de acesso',
        prefixIcon: Icon(Icons.admin_panel_settings_outlined),
      ),
      isExpanded: true,
      items: _rolesDisponiveis
          .map(
            (role) => DropdownMenuItem(
              value: role['value'],
              child: Text(role['label']!),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _roleSelecionado = value;
          });
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Selecione um perfil de acesso';
        }
        return null;
      },
    );
  }
}
