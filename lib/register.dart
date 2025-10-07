import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/course_option.dart';
import 'package:flutter_application_1/services/user_management_api.dart';

// Este arquivo agora é uma tela simples e não precisa de outros imports de navegação complexa.

// --- TELA DE CADASTRO DE USUÁRIO REATORADA ---
class RegisterScreen extends StatefulWidget {
  final String role; // Mantendo o parâmetro que você tinha.
  RegisterScreen({required this.role});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Seus controllers originais
  final _nomeController = TextEditingController();
  final _sobrenomeController = TextEditingController();
  final _loginController = TextEditingController();
  final _roleController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscureSenha = true;
  bool _obscureConfirmarSenha = true;
  bool _isLoadingCursos = false;
  List<CourseOption> _cursos = const [];
  String? _cursoSelecionadoId;

  @override
  void initState() {
    super.initState();
    _roleController.text = widget.role;
    _carregarCursos();
  }

  @override
  void dispose() {
    // Limpando todos os controllers
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
      final cursos = await UsuarioApi.listarCursos();
      if (!mounted) return;
      setState(() {
        _cursos = cursos;
        if (_cursos.isEmpty) {
          _cursoSelecionadoId = null;
        } else if (_cursoSelecionadoId != null &&
            !_cursos.any((c) => c.id == _cursoSelecionadoId)) {
          _cursoSelecionadoId = null;
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

  // Função para lidar com o cadastro do usuário
  Future<void> _cadastrarUsuario() async {
    // Valida o formulário antes de continuar.
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
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
    
    // --- LÓGICA DE API AQUI ---
    // Você vai criar um mapa com os dados a serem enviados.
    FocusScope.of(context).unfocus();

    try {
      final createdId = await UsuarioApi.criarUsuario(
        login: _loginController.text.trim(),
        curso: _cursoSelecionadoId!,
        nome: _nomeController.text.trim(),
        sobrenome: _sobrenomeController.text.trim(),
        senha: _senhaController.text,
        email: _emailController.text.trim(),
        role: _roleController.text.trim(),
      );

      if (!mounted) return;

      if (createdId != null && createdId.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Usuário criado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar usuário.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro inesperado: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text("Criar Novo Usuário"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(controller: _nomeController, decoration: InputDecoration(labelText: "Nome"), validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
              SizedBox(height: 16),
              TextFormField(controller: _sobrenomeController, decoration: InputDecoration(labelText: "Sobrenome"), validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
              SizedBox(height: 16),
              TextFormField(controller: _loginController, decoration: InputDecoration(labelText: "Login (nome de usuário)"), validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
              SizedBox(height: 16),
              TextFormField(controller: _roleController, decoration: InputDecoration(labelText: "Perfil (ex: admin, user)"), validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: "E-mail"),
                validator: (v) {
                  if (v!.isEmpty) return 'Campo obrigatório';
                  if (!v.contains('@')) return 'Email inválido';
                  return null;
                },
              ),
              SizedBox(height: 16),
              _buildCursoDropdown(),
              SizedBox(height: 16),
              TextFormField(
                controller: _senhaController,
                obscureText: _obscureSenha,
                decoration: InputDecoration(
                  labelText: "Senha",
                  suffixIcon: IconButton(icon: Icon(_obscureSenha ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscureSenha = !_obscureSenha)),
                ),
                validator: (v) {
                  if (v!.isEmpty) return 'Campo obrigatório';
                  if (v.length < 6) return 'A senha deve ter no mínimo 6 caracteres';
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _confirmarSenhaController,
                obscureText: _obscureConfirmarSenha,
                decoration: InputDecoration(
                  labelText: "Confirmar Senha",
                  suffixIcon: IconButton(icon: Icon(_obscureConfirmarSenha ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscureConfirmarSenha = !_obscureConfirmarSenha)),
                ),
                validator: (v) {
                  if (v != _senhaController.text) return 'As senhas não coincidem';
                  return null;
                },
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _cadastrarUsuario,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                    : Text("CADASTRAR"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCursoDropdown() {
    if (_isLoadingCursos) {
      return InputDecorator(
        decoration: InputDecoration(labelText: 'Curso'),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('Carregando cursos...'),
            ],
          ),
        ),
      );
    }

    if (_cursos.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InputDecorator(
            decoration: InputDecoration(labelText: 'Curso'),
            child: Text('Nenhum curso disponível.'),
          ),
          SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _carregarCursos,
            icon: Icon(Icons.refresh),
            label: Text('Tentar novamente'),
          ),
        ],
      );
    }

    return DropdownButtonFormField<String>(
      value: _cursoSelecionadoId,
      decoration: InputDecoration(labelText: 'Curso'),
      items: _cursos
          .map((curso) => DropdownMenuItem(
                value: curso.id,
                child: Text(curso.nome),
              ))
          .toList(),
      onChanged: (value) {
        setState(() {
          _cursoSelecionadoId = value;
        });
      },
      validator: (value) =>
          (value == null || value.isEmpty) ? 'Selecione um curso' : null,
    );
  }
}
