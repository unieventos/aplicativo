import 'package:flutter/material.dart';

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

  // Função para lidar com o cadastro do usuário
  Future<void> _cadastrarUsuario() async {
    // Valida o formulário antes de continuar.
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() => _isLoading = true);
    
    // --- LÓGICA DE API AQUI ---
    // Você vai criar um mapa com os dados a serem enviados.
    final dadosParaCriar = {
      'nome': _nomeController.text,
      'sobrenome': _sobrenomeController.text,
      'login': _loginController.text,
      'role': _roleController.text,
      'email': _emailController.text,
      'password': _senhaController.text,
      // 'cursoId': _idDoCursoSelecionado,
    };
    
    // Simula uma chamada à API.
    print("Enviando para API: $dadosParaCriar");
    await Future.delayed(Duration(seconds: 2));
    
    // Exemplo de como seria a chamada real:
    // final sucesso = await UsuarioApi.criarUsuario(dadosParaCriar);

    // if (sucesso && mounted) {
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Usuário criado com sucesso!"), backgroundColor: Colors.green));
    //   Navigator.of(context).pop(true); // Retorna 'true' para a tela anterior para atualizar a lista.
    // } else {
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro ao criar usuário."), backgroundColor: Colors.red));
    // }

    setState(() => _isLoading = false);
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
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: "Selecione o Curso"),
                items: ["Ciência da Computação", "Engenharia", "Direito"]
                    .map((curso) => DropdownMenuItem(value: curso, child: Text(curso)))
                    .toList(),
                onChanged: (value) {},
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
}