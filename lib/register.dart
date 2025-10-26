import 'package:flutter/material.dart';
import 'package:flutter_application_1/api_service.dart' as api_service;
import 'package:flutter_application_1/models/course_option.dart';
import 'package:flutter_application_1/services/user_management_api.dart';

// --- TELA DE CADASTRO DE USUÁRIO FINALIZADA ---
class RegisterScreen extends StatefulWidget {
  final String role;
  RegisterScreen({required this.role});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _sobrenomeController = TextEditingController();
  final _loginController = TextEditingController();
  final _roleController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  
  // Variável para armazenar o ID do curso selecionado.
  String? _cursoSelecionadoId; // Usando String para consistência com CourseOption
  
  bool _isLoading = false;
  bool _obscureSenha = true;
  bool _obscureConfirmarSenha = true;
  bool _isLoadingCursos = false;
  List<CourseOption> _cursos = const [];

  @override
  void initState() {
    super.initState();
    _roleController.text = widget.role;
    _carregarCursos();
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

  Future<void> _carregarCursos() async {
    setState(() => _isLoadingCursos = true);
    try {
      final cursos = await api_service.UsuarioApi.listarCursos();
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
        SnackBar(
          content: Text('Falha ao carregar cursos: $e'),
          backgroundColor: Colors.orange,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoadingCursos = false);
      }
    }
  }

  // Função para criar o usuário, agora conectada à API.
  Future<void> _criarUsuario() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_cursoSelecionadoId == null || _cursoSelecionadoId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selecione um curso'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Monta o mapa de dados para enviar à API
    final dadosParaCriar = {
      "nome": _nomeController.text.trim(),
      "sobrenome": _sobrenomeController.text.trim(),
      "login": _loginController.text.trim(),
      "email": _emailController.text.trim(),
      "senha": _senhaController.text,
      "role": _roleController.text.trim(),
      "curso": _cursoSelecionadoId!,
    };

    try {
      final sucesso = await api_service.UsuarioApi.criarUsuario(dadosParaCriar);

      if (mounted) {
        if (sucesso) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Usuário criado com sucesso!"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true); // Retorna 'true' para atualizar a lista anterior.
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Erro ao criar usuário."),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro inesperado: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Função para testar conectividade com a API.
  Future<void> _testarConectividade() async {
    try {
      final conectado = await api_service.UsuarioApi.testarConectividade();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(conectado ? "Conectado com sucesso!" : "Falha na conexão"),
            backgroundColor: conectado ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro ao testar conectividade: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cadastrar Usuário"),
        actions: [
          IconButton(
            icon: Icon(Icons.wifi),
            onPressed: _testarConectividade,
            tooltip: "Testar Conectividade",
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
              // Campo Nome
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(
                  labelText: "Nome",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Nome é obrigatório";
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Campo Sobrenome
              TextFormField(
                controller: _sobrenomeController,
                decoration: InputDecoration(
                  labelText: "Sobrenome",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Sobrenome é obrigatório";
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Campo Login
              TextFormField(
                controller: _loginController,
                decoration: InputDecoration(
                  labelText: "Login",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Login é obrigatório";
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Campo Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "E-mail",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "E-mail é obrigatório";
                  }
                  if (!value.contains('@')) {
                    return "E-mail inválido";
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Dropdown de Curso
              _buildCursoDropdown(),
              SizedBox(height: 16),

              // Campo Senha
              TextFormField(
                controller: _senhaController,
                decoration: InputDecoration(
                  labelText: "Senha",
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureSenha ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscureSenha = !_obscureSenha;
                      });
                    },
                  ),
                ),
                obscureText: _obscureSenha,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Senha é obrigatória";
                  }
                  if (value.length < 6) {
                    return "Senha deve ter pelo menos 6 caracteres";
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Campo Confirmar Senha
              TextFormField(
                controller: _confirmarSenhaController,
                decoration: InputDecoration(
                  labelText: "Confirmar Senha",
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmarSenha ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmarSenha = !_obscureConfirmarSenha;
                      });
                    },
                  ),
                ),
                obscureText: _obscureConfirmarSenha,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Confirmação de senha é obrigatória";
                  }
                  if (value != _senhaController.text) {
                    return "Senhas não coincidem";
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Campo Role (oculto)
              TextFormField(
                controller: _roleController,
                decoration: InputDecoration(
                  labelText: "Perfil",
                  border: OutlineInputBorder(),
                ),
                enabled: false,
              ),
              SizedBox(height: 24),

              // Botão Criar Usuário
              ElevatedButton(
                onPressed: _isLoading ? null : _criarUsuario,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Criar Usuário", style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCursoDropdown() {
    if (_isLoadingCursos) {
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 16),
            Text('Carregando cursos...'),
          ],
        ),
      );
    }

    return DropdownButtonFormField<String>(
      value: _cursoSelecionadoId,
      decoration: InputDecoration(
        labelText: "Curso",
        border: OutlineInputBorder(),
      ),
      items: _cursos.map((curso) => DropdownMenuItem(
        value: curso.id,
        child: Text(curso.nome),
      )).toList(),
      onChanged: (value) => setState(() => _cursoSelecionadoId = value),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Selecione um curso";
        }
        return null;
      },
    );
  }
}