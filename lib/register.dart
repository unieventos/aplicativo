import 'package:flutter/material.dart';
import 'package:flutter_application_1/api_service.dart'; // Importa a sua classe de API

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
  
  // Lista de cursos estática para preencher o dropdown.
  // No futuro, você pode buscar esta lista da sua API no initState.
  final List<Curso> _listaDeCursos = [
    Curso(id: 1, nome: "Ciência da Computação"),
    Curso(id: 2, nome: "Engenharia"),
    Curso(id: 3, nome: "Direito"),
    Curso(id: 4, nome: "Odontologia"),
    Curso(id: 5, nome: "Enfermagem"),
    Curso(id: 6, nome: "Pastoral"),
  ];
  
  // Variável para armazenar o ID do curso selecionado.
  int? _cursoSelecionadoId;
  
  bool _isLoading = false;
  bool _obscureSenha = true;
  bool _obscureConfirmarSenha = true;

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

  // Função de cadastro conectada à API.
  Future<void> _cadastrarUsuario() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    
    // Monta o mapa de dados para enviar à API, conforme o Swagger.
    final dadosParaCriar = {
      "login": _loginController.text.trim(),
      "cursoId": _cursoSelecionadoId, // CORREÇÃO: Enviando o ID do curso.
      "email": _emailController.text.trim(),
      "senha": _senhaController.text,
      "nome": _nomeController.text.trim(),
      "sobrenome": _sobrenomeController.text.trim(),
      "role": _roleController.text.trim()
    };
    // Atenção: O Swagger de criação não mostra 'cursoId', mas o de atualização sim.
    // Estou assumindo que o de criação também aceita. Se não, a chave pode ser 'curso' com o nome.

    final sucesso = await UsuarioApi.criarUsuario(dadosParaCriar);

    if (mounted) {
      if (sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Usuário criado com sucesso!"), backgroundColor: Colors.green));
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro ao criar usuário."), backgroundColor: Colors.red));
      }
      setState(() => _isLoading = false);
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
              TextFormField(controller: _roleController, decoration: InputDecoration(labelText: "Perfil (ex: ADMIN, USER)"), validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
              SizedBox(height: 16),
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
}