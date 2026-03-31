import 'package:flutter/material.dart';
import 'package:flutter_application_1/api_service.dart';
import 'package:flutter_application_1/models/course_option.dart';
import 'package:flutter_application_1/models/curso.dart';// --- TELA DE CADASTRO DE USUÁRIO FINALIZADA ---
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, this.role});

  final String? role;

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}
class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _sobrenomeController = TextEditingController();
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController = TextEditingController();

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao carregar cursos: $e')),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um curso')),
      );
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuário criado com sucesso!')),
          );
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao criar usuário.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro inesperado: $e')),
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(conectado ? 'Conectado com sucesso!' : 'Falha na conexão'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao testar conectividade: $e')),
        );
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isSmallScreen = constraints.maxWidth < 453;
        
        return DropdownButtonFormField<String>(
          value: _cursoSelecionadoId,
          decoration: InputDecoration(
            labelText: 'Curso',
            prefixIcon: isSmallScreen ? null : const Icon(Icons.school_outlined),
            contentPadding: isSmallScreen
                ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
                : const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          isExpanded: true,
          items: _cursos.map(
            (curso) => DropdownMenuItem(value: curso.id, child: Text(curso.nome)),
          ).toList(),
          selectedItemBuilder: (context) {
            return _cursos.map((curso) {
              return Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _cursos.firstWhere(
                    (c) => c.id == _cursoSelecionadoId,
                    orElse: () => _cursos.isNotEmpty ? _cursos.first : curso,
                  ).nome,
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
      items: _rolesDisponiveis.map(
        (role) => DropdownMenuItem(
          value: role['value'],
          child: Text(role['label']!),
        ),
      ).toList(),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar usuário'),
        actions: [
          IconButton(
            icon: const Icon(Icons.wifi_tethering_outlined),
            onPressed: _testarConectividade,
            tooltip: 'Testar conectividade',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nomeController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: "Nome", prefixIcon: Icon(Icons.person_outline)),
                validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _sobrenomeController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: "Sobrenome", prefixIcon: Icon(Icons.person_2_outlined)),
                validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: "E-mail", prefixIcon: Icon(Icons.alternate_email)),
                validator: (v) => (v!.isEmpty || !v.contains('@')) ? 'Email inválido' : null,
              ),
              const SizedBox(height: 16),
              _buildCursoDropdown(),
              const SizedBox(height: 24),
              const _SectionTitle('Acesso à plataforma'),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
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
                      const SizedBox(height: 16),
                      _buildRoleDropdown(),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _senhaController,
                        obscureText: _obscureSenha,
                        decoration: InputDecoration(
                          labelText: 'Senha provisória',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureSenha ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () => setState(() => _obscureSenha = !_obscureSenha),
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
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmarSenhaController,
                        obscureText: _obscureConfirmarSenha,
                        decoration: InputDecoration(
                          labelText: 'Confirmar senha',
                          prefixIcon: const Icon(Icons.lock_reset_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmarSenha ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () => setState(() => _obscureConfirmarSenha = !_obscureConfirmarSenha),
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
              const SizedBox(height: 32),
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
