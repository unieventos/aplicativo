import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/usuario.dart'; // Modelo Usuario centralizado
import 'package:flutter_application_1/api_service.dart'; // Importa a sua classe de API
import 'package:flutter_application_1/models/course_option.dart';
import 'package:flutter_application_1/models/managed_user.dart';
import 'package:flutter_application_1/services/user_management_api.dart';

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
  late TextEditingController _senhaController;
  bool _isLoadingCursos = false;
  List<CourseOption> _cursos = const [];
  String? _cursoSelecionadoId;
  bool _isLoading = false;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.usuario.nome);
    _sobrenomeController = TextEditingController(text: widget.usuario.sobrenome);
    _emailController = TextEditingController(text: widget.usuario.email);
    _senhaController = TextEditingController();
    _cursoSelecionadoId = widget.usuario.cursoId.isNotEmpty
        ? widget.usuario.cursoId
        : null;
    _carregarCursos();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _sobrenomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }
  
<<<<<<< HEAD
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

        if ((_cursoSelecionadoId == null || _cursoSelecionadoId!.isEmpty) &&
            widget.usuario.cursoNome.isNotEmpty) {
          final match = _cursos.firstWhere(
            (curso) =>
                curso.nome.toLowerCase() ==
                widget.usuario.cursoNome.toLowerCase(),
            orElse: () =>
                CourseOption(id: '', nome: ''),
          );
          if (match.id.isNotEmpty) {
            _cursoSelecionadoId = match.id;
          }
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

  // Função para lidar com o salvamento das alterações.
  Future<void> _salvarAlteracoes() async {
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

    final payload = {
      'nome': _nomeController.text.trim(),
      'sobrenome': _sobrenomeController.text.trim(),
      'email': _emailController.text.trim(),
      'curso': _cursoSelecionadoId!,
      if (_senhaController.text.isNotEmpty) 'senha': _senhaController.text,
    };

    try {
      final sucesso =
          await UsuarioApi.atualizarUsuario(widget.usuario.id, payload);
      if (!mounted) return;

      if (sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Usuário atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar usuário.'),
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
      if (mounted) {
        setState(() => _isLoading = false);
      }
>>>>>>> 61c5ee6444703dbf3c5f37cd6b3fa763c09ac204
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
                      backgroundColor:
                          Theme.of(context).primaryColor.withOpacity(0.1),
                      child: Text(
                        widget.usuario.initials,
                        style: TextStyle(
                            fontSize: 32,
                            color: Theme.of(context).primaryColor),
                      ),
                    ),
                    SizedBox(height: 8),
<<<<<<< HEAD
                    Text('Editando perfil de ${widget.usuario.nome}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
=======
                    Text(
                      'Editando perfil de ${widget.usuario.displayName}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text('Login: ${widget.usuario.login}'),
>>>>>>> 61c5ee6444703dbf3c5f37cd6b3fa763c09ac204
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
              
<<<<<<< HEAD
              DropdownButtonFormField<int>(
                value: _cursoSelecionadoId,
                decoration: InputDecoration(labelText: "Selecione o Curso"),
                items: _listaDeCursos.map((curso) => DropdownMenuItem(value: curso.id, child: Text(curso.nome))).toList(),
                onChanged: (value) => setState(() => _cursoSelecionadoId = value),
                validator: (v) => v == null ? 'Selecione um curso' : null,
              ),
=======
              _buildCursoDropdown(),
>>>>>>> 61c5ee6444703dbf3c5f37cd6b3fa763c09ac204
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
<<<<<<< HEAD
=======

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
          (value == null || value.isEmpty) ? 'Informe o curso' : null,
    );
  }
>>>>>>> 61c5ee6444703dbf3c5f37cd6b3fa763c09ac204
}
