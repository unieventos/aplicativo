import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:flutter_application_1/models/course_option.dart';
import 'package:flutter_application_1/models/managed_user.dart';
import 'package:flutter_application_1/modifyUser.dart';
import 'package:flutter_application_1/register.dart';
import 'package:flutter_application_1/services/user_management_api.dart';

// --- TELA DE GERENCIAMENTO (CURSOS & USUÁRIOS) ---
class CadastroUsuarioPage extends StatefulWidget {
  @override
  _CadastroUsuarioPageState createState() => _CadastroUsuarioPageState();
}

class _CadastroUsuarioPageState extends State<CadastroUsuarioPage>
    with SingleTickerProviderStateMixin {
  final _storage = FlutterSecureStorage();
  late final TabController _tabController;

  bool _isAdmin = false;
  bool _verificacaoConcluida = false;
  bool _operacaoEmAndamento = false;

  // --- ESTADO DE CURSOS ---
  final TextEditingController _buscaCursosController = TextEditingController();
  List<CourseOption> _cursos = const [];
  List<CourseOption> _cursosFiltrados = const [];
  bool _isLoadingCursos = false;
  Timer? _cursoDebounce;

  // --- ESTADO DE USUÁRIOS ---
  final TextEditingController _buscaUsuariosController = TextEditingController();
  final PagingController<int, ManagedUser> _pagingController =
      PagingController(firstPageKey: 0);
  String _usuarioBuscaAtual = '';
  Timer? _usuarioDebounce;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));

    _buscaCursosController.addListener(_onCursoBuscaChange);
    _buscaUsuariosController.addListener(_onUsuarioBuscaChange);
    _pagingController.addPageRequestListener(_fetchUsuariosPage);

    _verificarPermissao();
  }

  @override
  void dispose() {
    _cursoDebounce?.cancel();
    _usuarioDebounce?.cancel();
    _tabController.dispose();

    _buscaCursosController
      ..removeListener(_onCursoBuscaChange)
      ..dispose();
    _buscaUsuariosController
      ..removeListener(_onUsuarioBuscaChange)
      ..dispose();

    _pagingController.dispose();
    super.dispose();
  }

  void _verificarPermissao() async {
    final role = await _storage.read(key: 'role');
    final isAdmin = (role ?? '').toLowerCase() == 'admin';
    if (!mounted) return;
    setState(() {
      _isAdmin = isAdmin;
      _verificacaoConcluida = true;
    });
    if (isAdmin) {
      _carregarCursos();
    }
  }

  // ---------------------------------------------------------------------------
  // CURSOS
  // ---------------------------------------------------------------------------
  Future<void> _carregarCursos({bool mostrarLoader = true}) async {
    if (!_isAdmin) return;
    if (mostrarLoader) {
      setState(() => _isLoadingCursos = true);
    }
    try {
      final cursos = await UsuarioApi.listarCursos();
      if (!mounted) return;
      setState(() {
        _cursos = cursos;
        _cursosFiltrados = _filtrarCursos(cursos, _buscaCursosController.text);
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
      if (mounted && mostrarLoader) {
        setState(() => _isLoadingCursos = false);
      }
    }
  }

  void _onCursoBuscaChange() {
    if (_cursoDebounce?.isActive ?? false) _cursoDebounce!.cancel();
    _cursoDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        _cursosFiltrados =
            _filtrarCursos(_cursos, _buscaCursosController.text);
      });
    });
  }

  List<CourseOption> _filtrarCursos(List<CourseOption> origem, String query) {
    final termo = query.trim().toLowerCase();
    if (termo.isEmpty) return List<CourseOption>.from(origem);
    return origem
        .where((curso) =>
            curso.nome.toLowerCase().contains(termo) ||
            curso.id.toLowerCase().contains(termo))
        .toList();
  }

  Future<void> _exibirDialogoNovoCurso() async {
    final controller = TextEditingController();
    final resultado = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Novo curso'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Nome do curso',
            hintText: 'Ex: Ciência da Computação',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isEmpty) return;
              Navigator.of(ctx).pop(text);
            },
            child: Text('Criar'),
          ),
        ],
      ),
    );

    if (resultado == null || resultado.isEmpty) return;

    setState(() => _operacaoEmAndamento = true);
    try {
      final created = await UsuarioApi.criarCurso(resultado);
      if (!mounted) return;

      if (created != null) {
        setState(() {
          _cursos = [..._cursos, created];
          _cursosFiltrados =
              _filtrarCursos(_cursos, _buscaCursosController.text);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Curso criado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Não foi possível criar o curso.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao criar curso: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _operacaoEmAndamento = false);
      }
    }
  }

  Future<void> _renomearCurso(CourseOption curso) async {
    final controller = TextEditingController(text: curso.nome);
    final novoNome = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Renomear curso'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: 'Nome do curso'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final texto = controller.text.trim();
              if (texto.isEmpty) return;
              Navigator.of(ctx).pop(texto);
            },
            child: Text('Salvar'),
          ),
        ],
      ),
    );

    if (novoNome == null || novoNome.isEmpty || novoNome == curso.nome) return;

    setState(() => _operacaoEmAndamento = true);
    try {
      final sucesso = await UsuarioApi.atualizarCurso(curso.id, novoNome);
      if (!mounted) return;

      if (sucesso) {
        setState(() {
          _cursos = _cursos
              .map((c) => c.id == curso.id
                  ? CourseOption(id: c.id, nome: novoNome)
                  : c)
              .toList();
          _cursosFiltrados =
              _filtrarCursos(_cursos, _buscaCursosController.text);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Curso atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Não foi possível atualizar o curso.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar curso: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _operacaoEmAndamento = false);
      }
    }
  }

  Future<void> _deletarCurso(CourseOption curso) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Excluir curso'),
        content: Text('Deseja realmente remover "${curso.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() => _operacaoEmAndamento = true);
    try {
      final sucesso = await UsuarioApi.deletarCurso(curso.id);
      if (!mounted) return;

      if (sucesso) {
        setState(() {
          _cursos = _cursos.where((c) => c.id != curso.id).toList();
          _cursosFiltrados =
              _filtrarCursos(_cursos, _buscaCursosController.text);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Curso removido com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Não foi possível remover o curso.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao remover curso: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _operacaoEmAndamento = false);
      }
    }
  }

  // ---------------------------------------------------------------------------
  // USUÁRIOS
  // ---------------------------------------------------------------------------
  void _onUsuarioBuscaChange() {
    if (_usuarioDebounce?.isActive ?? false) _usuarioDebounce!.cancel();
    _usuarioDebounce = Timer(const Duration(milliseconds: 400), () {
      final novoValor = _buscaUsuariosController.text.trim();
      if (novoValor == _usuarioBuscaAtual) return;
      _usuarioBuscaAtual = novoValor;
      _pagingController.refresh();
    });
  }

  Future<void> _fetchUsuariosPage(int pageKey) async {
    try {
      final usuarios = await UsuarioApi.fetchUsuarios(
        pageKey,
        10,
        _usuarioBuscaAtual,
      );
      final isLastPage = usuarios.length < 10;
      if (isLastPage) {
        _pagingController.appendLastPage(usuarios);
      } else {
        _pagingController.appendPage(usuarios, pageKey + 1);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  Future<void> _onDeleteUser(String userId) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Excluir usuário'),
        content: Text('Deseja realmente remover este usuário?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Excluindo usuário...'),
        duration: Duration(seconds: 1),
      ),
    );

    final sucesso = await UsuarioApi.deletarUsuario(userId);
    if (!mounted) return;

    if (sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Usuário removido com sucesso'),
          backgroundColor: Colors.green,
        ),
      );
      _pagingController.refresh();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha ao remover usuário'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _abrirCadastroUsuario() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegisterScreen(role: 'admin'),
      ),
    ).then((shouldRefresh) {
      if (shouldRefresh == true) {
        _pagingController.refresh();
      }
    });
  }

  void _abrirEdicaoUsuario(ManagedUser usuario) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ModifyUserApp(usuario: usuario),
      ),
    ).then((shouldRefresh) {
      if (shouldRefresh == true) {
        _pagingController.refresh();
      }
    });
  }

  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Gerenciar'),
        centerTitle: false,
        bottom: _isAdmin
            ? TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Cursos'),
                  Tab(text: 'Usuários'),
                ],
              )
            : null,
      ),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget? _buildFloatingActionButton() {
    if (!_verificacaoConcluida || !_isAdmin) return null;
    if (_tabController.index == 0) {
      return FloatingActionButton.extended(
        onPressed: _operacaoEmAndamento ? null : _exibirDialogoNovoCurso,
        icon: Icon(Icons.add),
        label: Text('Novo Curso'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      );
    }
    return FloatingActionButton.extended(
      onPressed: _abrirCadastroUsuario,
      icon: Icon(Icons.person_add_alt_1_outlined),
      label: Text('Novo Usuário'),
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
    );
  }

  Widget _buildBody() {
    if (!_verificacaoConcluida) {
      return Center(child: CircularProgressIndicator());
    }

    if (!_isAdmin) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 48, color: Colors.grey[600]),
              SizedBox(height: 16),
              Text(
                'Acesso permitido apenas para administradores.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildCursosTab(),
        _buildUsuariosTab(),
      ],
    );
  }

  Widget _buildCursosTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _buscaCursosController,
            decoration: InputDecoration(
              hintText: 'Pesquisar cursos...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _carregarCursos(mostrarLoader: false),
            child: _isLoadingCursos && _cursos.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(
                        height: 200,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ],
                  )
                : _cursosFiltrados.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(
                            height: 200,
                            child: Center(child: Text('Nenhum curso encontrado.')),
                          ),
                        ],
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        itemCount: _cursosFiltrados.length,
                        itemBuilder: (context, index) {
                          final curso = _cursosFiltrados[index];
                          return _CursoListItem(
                            curso: curso,
                            onRename: () => _renomearCurso(curso),
                            onDelete: () => _deletarCurso(curso),
                          );
                        },
                      ),
          ),
        ),
      ],
    );
  }

  Widget _buildUsuariosTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _buscaUsuariosController,
            decoration: InputDecoration(
              hintText: 'Pesquisar usuários...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => Future.sync(_pagingController.refresh),
            child: PagedListView<int, ManagedUser>(
              pagingController: _pagingController,
              builderDelegate: PagedChildBuilderDelegate<ManagedUser>(
                itemBuilder: (context, usuario, index) => _UsuarioListItem(
                  usuario: usuario,
                  onDelete: () => _onDeleteUser(usuario.id),
                  onModify: () => _abrirEdicaoUsuario(usuario),
                ),
                firstPageProgressIndicatorBuilder: (_) =>
                    Center(child: CircularProgressIndicator()),
                newPageProgressIndicatorBuilder: (_) =>
                    Center(child: CircularProgressIndicator()),
                noItemsFoundIndicatorBuilder: (_) =>
                    Center(child: Text('Nenhum usuário encontrado.')),
                firstPageErrorIndicatorBuilder: (_) =>
                    Center(child: Text('Erro ao carregar usuários.')),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CursoListItem extends StatelessWidget {
  const _CursoListItem({
    required this.curso,
    required this.onRename,
    required this.onDelete,
  });

  final CourseOption curso;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  String get _initials {
    final trimmed = curso.nome.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          foregroundColor: Theme.of(context).primaryColor,
          child: Text(_initials),
        ),
        title: Text(
          curso.nome,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('ID: ${curso.id}'),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onRename,
                  icon: Icon(Icons.edit, size: 18),
                  label: Text('Renomear'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue.shade700,
                  ),
                ),
                SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: Icon(Icons.delete_outline, size: 18),
                  label: Text('Excluir'),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UsuarioListItem extends StatelessWidget {
  const _UsuarioListItem({
    required this.usuario,
    required this.onDelete,
    required this.onModify,
  });

  final ManagedUser usuario;
  final VoidCallback onDelete;
  final VoidCallback onModify;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          foregroundColor: Theme.of(context).primaryColor,
          child: Text(usuario.initials),
        ),
        title: Text(
          usuario.displayName,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('${usuario.email}\nLogin: ${usuario.login}'),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Curso: ${usuario.cursoDisplay.isNotEmpty ? usuario.cursoDisplay : 'Não informado'}',
                ),
                SizedBox(height: 4),
                Text(
                  'Perfil: ${usuario.role.isNotEmpty ? usuario.role.toUpperCase() : 'USER'}',
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: onModify,
                      icon: Icon(Icons.edit, size: 18),
                      label: Text('Modificar'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue.shade700,
                      ),
                    ),
                    SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: onDelete,
                      icon: Icon(Icons.delete_outline, size: 18),
                      label: Text('Excluir'),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
