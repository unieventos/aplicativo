import 'package:flutter/material.dart';
import 'package:flutter_application_1/api_service.dart'; // Importa a sua classe de API
import 'package:flutter_application_1/models/course_option.dart';
import 'package:flutter_application_1/services/user_management_api.dart';

// --- MODELO DE DADOS PARA CURSO (Exemplo) ---
// O ideal é que este modelo e a lista abaixo venham da sua API.
class Curso {
  final int id;
  final String nome;
  Curso({required this.id, required this.nome});
}

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
  
  // Lista COMPLETA dos 38 cursos pré-cadastrados no banco de dados
  // Nomes EXATOS conforme cadastrados na API
  final List<Curso> _listaDeCursos = [
    Curso(id: 1, nome: "Administração"),
    Curso(id: 2, nome: "Arquitetura e Urbanismo"),
    Curso(id: 3, nome: "Artes"),
    Curso(id: 4, nome: "Biomedicina"),
    Curso(id: 5, nome: "Celulose e Papel"),
    Curso(id: 6, nome: "Ciência da Computação"),
    Curso(id: 7, nome: "Ciências Biológicas Bacharelado"),
    Curso(id: 8, nome: "Ciências Biológicas Licenciatura"),
    Curso(id: 9, nome: "Ciências Contábeis"),
    Curso(id: 10, nome: "Design"),
    Curso(id: 11, nome: "Design de Moda"),
    Curso(id: 12, nome: "Educação Física - Bacharelado"),
    Curso(id: 13, nome: "Educação Física - Licenciatura"),
    Curso(id: 14, nome: "Enfermagem"),
    Curso(id: 15, nome: "Engenharia Agronômica"),
    Curso(id: 16, nome: "Engenharia Civil"),
    Curso(id: 17, nome: "Engenharia de Computação"),
    Curso(id: 18, nome: "Engenharia de Produção"),
    Curso(id: 19, nome: "Engenharia Elétrica"),
    Curso(id: 20, nome: "Engenharia Mecânica"),
    Curso(id: 21, nome: "Engenharia Química"),
    Curso(id: 22, nome: "Estética e Cosmética"),
    Curso(id: 23, nome: "Farmácia"),
    Curso(id: 24, nome: "Fisioterapia"),
    Curso(id: 25, nome: "Gastronomia"),
    Curso(id: 26, nome: "História"),
    Curso(id: 27, nome: "Jogos Digitais"),
    Curso(id: 28, nome: "Jornalismo"),
    Curso(id: 29, nome: "Letras - Português e Inglês - Licenciatura"),
    Curso(id: 30, nome: "Letras - Tradutor - Bacharelado"),
    Curso(id: 31, nome: "Matemática"),
    Curso(id: 32, nome: "Nutrição"),
    Curso(id: 33, nome: "Odontologia"),
    Curso(id: 34, nome: "Pedagogia"),
    Curso(id: 35, nome: "Psicologia"),
    Curso(id: 36, nome: "Publicidade e Propaganda"),
    Curso(id: 37, nome: "Relações Internacionais"),
    Curso(id: 38, nome: "Teatro"),
  ];
  
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

<<<<<<< HEAD
  // Função de cadastro conectada à API.
  Future<void> _cadastrarUsuario() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    
    try {
      // Valida se o curso foi selecionado
      if (_cursoSelecionadoId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Selecione um curso"), backgroundColor: Colors.orange)
        );
        setState(() => _isLoading = false);
        return;
      }

      // Monta o mapa de dados para enviar à API no formato correto
      final cursoSelecionado = _listaDeCursos.firstWhere((curso) => curso.id == _cursoSelecionadoId);
      
      final dadosParaCriar = {
        "login": _loginController.text.trim(),
        "curso": cursoSelecionado.nome, // API espera nome do curso, não ID
        "email": _emailController.text.trim(),
        "senha": _senhaController.text,
        "nome": _nomeController.text.trim(),
        "sobrenome": _sobrenomeController.text.trim(),
        "role": _roleController.text.trim() // API espera exatamente "admin" ou "usuario"
      };

      final sucesso = await UsuarioApi.criarUsuario(dadosParaCriar);

      if (mounted) {
        if (sucesso) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Usuário criado com sucesso!"), 
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            )
          );
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Erro ao criar usuário. Verifique os dados e tente novamente."), 
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
            )
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro de conexão: $e"), 
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          )
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Método para testar conectividade com a API
  Future<void> _testarConectividade() async {
    setState(() => _isLoading = true);
    
    try {
      final conectado = await UsuarioApi.testarConectividade();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(conectado ? "Conectividade OK!" : "Erro de conectividade"),
            backgroundColor: conectado ? Colors.green : Colors.red,
            duration: Duration(seconds: 3),
          )
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro no teste: $e"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          )
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
=======
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
>>>>>>> 61c5ee6444703dbf3c5f37cd6b3fa763c09ac204
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
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: "Perfil"),
                value: _roleController.text.isNotEmpty ? _roleController.text : null,
                items: [
                  DropdownMenuItem(value: 'ADMIN', child: Text('Administrador')),
                  DropdownMenuItem(value: 'GESTOR', child: Text('Gestor')),
                  DropdownMenuItem(value: 'COLABORADOR', child: Text('Colaborador')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    _roleController.text = value;
                  }
                },
                validator: (v) => v == null || v.isEmpty ? 'Selecione um perfil' : null,
              ),
              SizedBox(height: 16),
<<<<<<< HEAD
              TextFormField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: InputDecoration(labelText: "E-mail"), validator: (v) => (v!.isEmpty || !v.contains('@')) ? 'Email inválido' : null),
              SizedBox(height: 16),
              
              // --- DROPDOWN CORRIGIDO PARA USAR ID ---
              DropdownButtonFormField<int>(
                decoration: InputDecoration(labelText: "Selecione o Curso"),
                value: _cursoSelecionadoId,
                items: _listaDeCursos.map((curso) {
                  // O valor de cada item é o ID, mas o que é exibido é o Nome.
                  return DropdownMenuItem(value: curso.id, child: Text(curso.nome));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _cursoSelecionadoId = value;
                  });
                },
                validator: (v) => v == null ? 'Selecione um curso' : null,
              ),
=======
              _buildCursoDropdown(),
>>>>>>> 61c5ee6444703dbf3c5f37cd6b3fa763c09ac204
              SizedBox(height: 16),
              TextFormField(
                controller: _senhaController,
                obscureText: _obscureSenha,
                decoration: InputDecoration(
                  labelText: "Senha",
                  suffixIcon: IconButton(icon: Icon(_obscureSenha ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscureSenha = !_obscureSenha)),
                ),
                validator: (v) => (v!.isEmpty || v.length < 6) ? 'A senha deve ter no mínimo 6 caracteres' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _confirmarSenhaController,
                obscureText: _obscureConfirmarSenha,
                decoration: InputDecoration(
                  labelText: "Confirmar Senha",
                  suffixIcon: IconButton(icon: Icon(_obscureConfirmarSenha ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscureConfirmarSenha = !_obscureConfirmarSenha)),
                ),
                validator: (v) => (v != _senhaController.text) ? 'As senhas não coincidem' : null,
              ),
              SizedBox(height: 16),
              // Botão de teste de conectividade
              OutlinedButton(
                onPressed: _isLoading ? null : _testarConectividade,
                child: Text("Testar Conectividade"),
              ),
              SizedBox(height: 16),
              
              
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
