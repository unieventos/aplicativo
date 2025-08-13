import 'package:flutter/material.dart';

// Importe o modelo de dados 'Usuario' do seu arquivo UserRegister.dart
// Isso garante que estamos trabalhando com o mesmo tipo de objeto.
import 'package:flutter_application_1/UserRegister.dart'; 

// --- TELA DE MODIFICAÇÃO DE USUÁRIO REATORADA ---
class ModifyUserApp extends StatefulWidget {
  // A tela agora recebe o objeto 'Usuario' inteiro, o que é mais limpo.
  final Usuario usuario;

  const ModifyUserApp({Key? key, required this.usuario}) : super(key: key);

  @override
  _ModifyUserAppState createState() => _ModifyUserAppState();
}

class _ModifyUserAppState extends State<ModifyUserApp> {
  final _formKey = GlobalKey<FormState>();

  // Controllers para os campos do formulário.
  late TextEditingController _nomeController;
  late TextEditingController _sobrenomeController; // Adicionado para consistência
  late TextEditingController _emailController;
  late TextEditingController _senhaController;
  String? _cursoSelecionado;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Inicializa os controllers com os dados do usuário recebido.
    _nomeController = TextEditingController(text: widget.usuario.nome);
    _sobrenomeController = TextEditingController(text: widget.usuario.sobrenome);
    _emailController = TextEditingController(text: widget.usuario.email);
    _senhaController = TextEditingController();
    
    // TODO: A lógica do curso precisa ser ajustada.
    // O ideal é ter uma lista de cursos (com ID e Nome) vinda da API.
    // Por enquanto, usaremos uma lista estática.
    _cursoSelecionado = "Engenharia"; // Exemplo
  }

  @override
  void dispose() {
    // Limpando todos os controllers para evitar vazamento de memória.
    _nomeController.dispose();
    _sobrenomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }
  
  // Função para lidar com o salvamento das alterações.
  Future<void> _salvarAlteracoes() async {
    // Valida o formulário antes de continuar.
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() => _isLoading = true);
    
    // --- LÓGICA DE API AQUI ---
    // Você vai criar um mapa com os dados a serem enviados.
    final dadosParaAtualizar = {
      'nome': _nomeController.text,
      'sobrenome': _sobrenomeController.text,
      'email': _emailController.text,
      // Envie a senha apenas se o campo não estiver vazio.
      if (_senhaController.text.isNotEmpty) 'password': _senhaController.text,
      // 'cursoId': _idDoCursoSelecionado, // Você precisará do ID do curso
    };
    
    // Simula uma chamada à API.
    await Future.delayed(Duration(seconds: 2));
    
    // Exemplo de como seria a chamada real:
    // final sucesso = await UsuarioApi.atualizarUsuario(widget.usuario.id, dadosParaAtualizar);

    // if (sucesso && mounted) {
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Usuário atualizado com sucesso!"), backgroundColor: Colors.green));
    //   Navigator.of(context).pop(true); // Retorna 'true' para indicar que a lista deve ser atualizada.
    // } else {
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro ao atualizar usuário."), backgroundColor: Colors.red));
    // }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    // A tela agora usa um Scaffold padrão, o que simplifica o código.
    return Scaffold(
      appBar: AppBar(
        title: Text("Modificar Usuário"),
        // A cor é herdada do tema global definido no main.dart
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar e nome do usuário no topo para uma melhor UX.
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                      child: Text(
                        widget.usuario.nome.isNotEmpty ? widget.usuario.nome[0].toUpperCase() : 'U',
                        style: TextStyle(fontSize: 32, color: Theme.of(context).primaryColor),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Editando perfil de ${widget.usuario.nome}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32),
              
              // Campo Nome
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(labelText: "Nome"),
                validator: (value) => (value == null || value.isEmpty) ? 'O nome não pode ser vazio' : null,
              ),
              SizedBox(height: 16),
              
              // Campo Sobrenome
              TextFormField(
                controller: _sobrenomeController,
                decoration: InputDecoration(labelText: "Sobrenome"),
                validator: (value) => (value == null || value.isEmpty) ? 'O sobrenome não pode ser vazio' : null,
              ),
              SizedBox(height: 16),
              
              // Campo E-mail
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: "E-mail"),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'O email não pode ser vazio';
                  if (!value.contains('@')) return 'Email inválido';
                  return null;
                },
              ),
              SizedBox(height: 16),
              
              // Campo Curso
              DropdownButtonFormField<String>(
                value: _cursoSelecionado,
                decoration: InputDecoration(labelText: "Selecione o Curso"),
                items: ["Ciência da Computação", "Engenharia", "Direito"]
                    .map((curso) => DropdownMenuItem(value: curso, child: Text(curso)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _cursoSelecionado = value;
                  });
                },
              ),
              SizedBox(height: 16),
              
              // Campo Nova Senha
              TextFormField(
                controller: _senhaController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Nova Senha (opcional)",
                  helperText: "Deixe em branco para não alterar a senha",
                ),
              ),
              SizedBox(height: 32),
              
              // Botão Salvar com indicador de carregamento
              ElevatedButton(
                onPressed: _isLoading ? null : _salvarAlteracoes,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                    : Text("SALVAR ALTERAÇÕES"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}