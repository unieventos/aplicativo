import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/app_theme.dart';
import 'package:flutter_application_1/models/course_option.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:flutter_application_1/widgets/app_feedback.dart';
import 'package:flutter_application_1/widgets/branded_header.dart';
import 'package:flutter_application_1/widgets/section_title.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, this.role});

  final String? role;

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _sobrenomeController = TextEditingController();
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController =
      TextEditingController();

  List<CourseOption> _cursos = const [];
  bool _isLoadingCursos = true;
  String? _cursoSelecionadoId;
  String? _roleSelecionado;

  bool _isLoading = false;
  bool _obscureSenha = true;
  bool _obscureConfirmarSenha = true;

  static const List<Map<String, String>> _rolesDisponiveis = [
    {'value': 'ADMIN', 'label': 'Administrador'},
    {'value': 'GESTOR', 'label': 'Gestor'},
    {'value': 'COLABORADOR', 'label': 'Colaborador'},
  ];

  @override
  void initState() {
    super.initState();
    _roleSelecionado = widget.role ?? 'COLABORADOR';
    _roleController.text = _roleSelecionado ?? '';
    _carregarCursos();
  }

  Future<void> _carregarCursos() async {
    setState(() => _isLoadingCursos = true);
    try {
      final cursos = await UsuarioApi.listarCursos();
      if (!mounted) return;
      setState(() {
        _cursos = cursos;
        if (_cursos.isNotEmpty) {
          _cursoSelecionadoId = _cursos.first.id;
        }
      });
    } catch (e) {
      if (!mounted) return;
      AppFeedback.error(context, 'Falha ao carregar cursos: $e');
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
    _loginController.dispose();
    _roleController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> _criarUsuario() async {
    if (!_formKey.currentState!.validate()) return;

    if (_cursoSelecionadoId == null || _cursoSelecionadoId!.isEmpty) {
      AppFeedback.error(context, 'Selecione um curso');
      return;
    }

    setState(() => _isLoading = true);

    final dadosParaCriar = {
      "nome": _nomeController.text.trim(),
      "sobrenome": _sobrenomeController.text.trim(),
      "login": _loginController.text.trim(),
      "email": _emailController.text.trim(),
      "senha": _senhaController.text,
      "role": _roleSelecionado ?? 'COLABORADOR',
      "curso": _cursoSelecionadoId!,
    };

    try {
      final sucesso = await UsuarioApi.criarUsuario(dadosParaCriar);

      if (mounted) {
        if (sucesso) {
          AppFeedback.success(context, 'Usuário criado com sucesso!');
          Navigator.of(context).pop(true);
        } else {
          AppFeedback.error(context, 'Erro ao criar usuário.');
        }
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.error(context, 'Erro inesperado: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _testarConectividade() async {
    try {
      final conectado = await UsuarioApi.testarConectividade();
      if (mounted) {
        if (conectado) {
          AppFeedback.success(context, 'Conectado com sucesso!');
        } else {
          AppFeedback.error(context, 'Falha na conexão');
        }
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.error(context, 'Erro ao testar conectividade: $e');
      }
    }
  }

  Widget _buildCursoDropdown() {
    if (_isLoadingCursos) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
          color: AppColors.surface,
        ),
        child: const Row(
          children: [
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isSmallScreen = constraints.maxWidth < 453;

        return DropdownButtonFormField<String>(
          value: _cursoSelecionadoId,
          decoration: InputDecoration(
            labelText: 'Curso',
            prefixIcon:
                isSmallScreen ? null : const Icon(Icons.school_outlined),
            contentPadding: isSmallScreen
                ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
                : const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          isExpanded: true,
          items: _cursos
              .map(
                (curso) =>
                    DropdownMenuItem(value: curso.id, child: Text(curso.nome)),
              )
              .toList(),
          selectedItemBuilder: (context) {
            return _cursos.map((curso) {
              return Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _cursos
                      .firstWhere(
                        (c) => c.id == _cursoSelecionadoId,
                        orElse: () =>
                            _cursos.isNotEmpty ? _cursos.first : curso,
                      )
                      .nome,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black87),
                ),
              );
            }).toList();
          },
          onChanged: (value) => setState(() => _cursoSelecionadoId = value),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Selecione um curso";
            }
            return null;
          },
        );
      },
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
            _roleController.text = value;
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

  @override
  Widget build(BuildContext context) {
    return BrandedScaffold(
      header: BrandedHeader(
        title: 'Criar usuário',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onPrimary),
          onPressed: () => Navigator.maybePop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.wifi_tethering_outlined,
              color: AppColors.onPrimary,
            ),
            onPressed: _testarConectividade,
            tooltip: 'Testar conectividade',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nomeController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                    labelText: "Nome", prefixIcon: Icon(Icons.person_outline)),
                validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _sobrenomeController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                    labelText: "Sobrenome",
                    prefixIcon: Icon(Icons.person_2_outlined)),
                validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                    labelText: "E-mail",
                    prefixIcon: Icon(Icons.alternate_email)),
                validator: (v) =>
                    (v!.isEmpty || !v.contains('@')) ? 'Email inválido' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              _buildCursoDropdown(),
              const SizedBox(height: AppSpacing.lg),
              const SectionTitle('Acesso à plataforma'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _loginController,
                        decoration: const InputDecoration(
                          labelText: 'Login',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Login é obrigatório';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildRoleDropdown(),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: _senhaController,
                        obscureText: _obscureSenha,
                        decoration: InputDecoration(
                          labelText: 'Senha provisória',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureSenha
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () =>
                                setState(() => _obscureSenha = !_obscureSenha),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Senha é obrigatória';
                          }
                          if (value.length < 6) {
                            return 'Senha deve ter pelo menos 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: _confirmarSenhaController,
                        obscureText: _obscureConfirmarSenha,
                        decoration: InputDecoration(
                          labelText: 'Confirmar senha',
                          prefixIcon: const Icon(Icons.lock_reset_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmarSenha
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () => setState(() =>
                                _obscureConfirmarSenha =
                                    !_obscureConfirmarSenha),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Confirmação de senha é obrigatória';
                          }
                          if (value != _senhaController.text) {
                            return 'Senhas não coincidem';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _criarUsuario,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Icon(Icons.save_alt_outlined),
                label: Text(_isLoading ? 'Enviando...' : 'Criar usuário'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
