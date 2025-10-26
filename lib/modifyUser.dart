import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/usuario.dart'; // Modelo Usuario centralizado
import 'package:flutter_application_1/api_service.dart'; // Importa a sua classe de API

// Modelo de Curso (exemplo, para lidar com ID e Nome)
class Curso {
  final int id;
  final String nome;
  Curso({required this.id, required this.nome});
}

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
  final _senhaController = TextEditingController();
  
  int? _cursoSelecionadoId;
  bool _isLoading = false;
  bool _obscureText = true;
  
  // Lista de cursos de exemplo. No mundo real, esta lista viria da API.
  final List<Curso> _listaDeCursos = [
    Curso(id: 1, nome: "Ciência da Computação"),
    Curso(id: 2, nome: "Engenharia"),
    Curso(id: 3, nome: "Direito"),
  ];

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.usuario.nome);
    _sobrenomeController = TextEditingController(text: widget.usuario.sobrenome);
    _emailController = TextEditingController(text: widget.usuario.email);
    _cursoSelecionadoId = widget.usuario.cursoId;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _sobrenomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }
  
  // Função para salvar as alterações, agora conectada à API.
  Future<void> _salvarAlteracoes() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    
    // Monta o mapa de dados para enviar à API, conforme o Swagger (usando PATCH).
    final dadosParaAtualizar = {
      "nome": _nomeController.text.trim(),
      "sobrenome": _sobrenomeController.text.trim(),
      "email": _emailController.text.trim(),
      "cursoId": _cursoSelecionadoId,
      // Envia a senha apenas se o campo não estiver vazio.
      if (_senhaController.text.isNotEmpty) "senha": _senhaController.text,
    };
    
    // Chama o método da API para atualizar o usuário.
    final sucesso = await UsuarioApi.atualizarUsuario(widget.usuario.id, dadosParaAtualizar);

    if (mounted) {
      if (sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Usuário atualizado com sucesso!"), backgroundColor: Colors.green));
        Navigator.of(context).pop(true); // Retorna 'true' para atualizar a lista anterior.
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro ao atualizar usuário."), backgroundColor: Colors.red));
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Modificar Usuário"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                    Text('Editando perfil de ${widget.usuario.nome}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              SizedBox(height: 32),
              
              TextFormField(controller: _nomeController, decoration: InputDecoration(labelText: "Nome"), validator: (v) => v!.isEmpty ? 'O nome não pode ser vazio' : null),
              SizedBox(height: 16),
              
              TextFormField(controller: _sobrenomeController, decoration: InputDecoration(labelText: "Sobrenome"), validator: (v) => v!.isEmpty ? 'O sobrenome não pode ser vazio' : null),
              SizedBox(height: 16),
              
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: "E-mail"),
                validator: (v) => (v!.isEmpty || !v.contains('@')) ? 'Email inválido' : null,
              ),
              SizedBox(height: 16),
              
              DropdownButtonFormField<int>(
                value: _cursoSelecionadoId,
                decoration: InputDecoration(labelText: "Selecione o Curso"),
                items: _listaDeCursos.map((curso) => DropdownMenuItem(value: curso.id, child: Text(curso.nome))).toList(),
                onChanged: (value) => setState(() => _cursoSelecionadoId = value),
                validator: (v) => v == null ? 'Selecione um curso' : null,
              ),
              SizedBox(height: 16),
              
              TextFormField(
                controller: _senhaController,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  labelText: "Nova Senha (opcional)",
                  helperText: "Deixe em branco para não alterar a senha",
                  suffixIcon: IconButton(
                    icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscureText = !_obscureText),
                  )
                ),
              ),
              SizedBox(height: 32),
              
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
