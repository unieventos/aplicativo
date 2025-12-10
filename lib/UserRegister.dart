import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:flutter_application_1/models/course_option.dart';
import 'package:flutter_application_1/models/usuario.dart';
import 'package:flutter_application_1/modifyUser.dart';
import 'package:flutter_application_1/register.dart';
import 'package:flutter_application_1/services/user_management_api.dart';
import 'package:flutter_application_1/user_service.dart';
import 'package:flutter_application_1/api_service.dart' as api_service;

// --- TELA DE GERENCIAMENTO (CURSOS & USUÁRIOS) ---
class CadastroUsuarioPage extends StatefulWidget {
  const CadastroUsuarioPage({super.key});

  @override
  _CadastroUsuarioPageState createState() => _CadastroUsuarioPageState();
}

class _CadastroUsuarioPageState extends State<CadastroUsuarioPage>
    with SingleTickerProviderStateMixin {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
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

  // --- ESTADO DE USUÁRIOS ATIVOS ---
  final TextEditingController _buscaUsuariosAtivosController =
      TextEditingController();
  final PagingController<int, Usuario> _pagingControllerAtivos =
      PagingController(
    firstPageKey: 0,
  );
  String _usuarioBuscaAtivosAtual = '';
  Timer? _usuarioAtivosDebounce;

  // --- ESTADO DE USUÁRIOS DESATIVADOS ---
  final TextEditingController _buscaUsuariosDesativadosController =
      TextEditingController();
  final PagingController<int, Usuario> _pagingControllerDesativados =
      PagingController(
    firstPageKey: 0,
  );
  String _usuarioBuscaDesativadosAtual = '';
  Timer? _usuarioDesativadosDebounce;

  // Cache local de status de usuários (em memória)
  // Armazena IDs de usuários que foram desativados/ativados nesta sessão
  final Set<String> _usuariosDesativadosCache = <String>{};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));

    _buscaCursosController.addListener(_onCursoBuscaChange);
    _buscaUsuariosAtivosController.addListener(_onUsuarioAtivosBuscaChange);
    _buscaUsuariosDesativadosController
        .addListener(_onUsuarioDesativadosBuscaChange);
    _pagingControllerAtivos.addPageRequestListener(_fetchUsuariosAtivosPage);
    _pagingControllerDesativados
        .addPageRequestListener(_fetchUsuariosDesativadosPage);

    _verificarPermissao();
  }

  @override
  void dispose() {
    _cursoDebounce?.cancel();
    _usuarioAtivosDebounce?.cancel();
    _usuarioDesativadosDebounce?.cancel();
    _tabController.dispose();

    _buscaCursosController
      ..removeListener(_onCursoBuscaChange)
      ..dispose();
    _buscaUsuariosAtivosController
      ..removeListener(_onUsuarioAtivosBuscaChange)
      ..dispose();
    _buscaUsuariosDesativadosController
      ..removeListener(_onUsuarioDesativadosBuscaChange)
      ..dispose();

    _pagingControllerAtivos.dispose();
    _pagingControllerDesativados.dispose();
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
    if (mostrarLoader) {
      setState(() => _isLoadingCursos = true);
    }
    try {
      final cursos = await api_service.UsuarioApi.listarCursos();
      if (!mounted) return;
      setState(() {
        _cursos = cursos;
        _cursosFiltrados = _filtrarCursos(cursos, _buscaCursosController.text);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Falha ao carregar cursos: $e')));
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
        _cursosFiltrados = _filtrarCursos(_cursos, _buscaCursosController.text);
      });
    });
  }

  List<CourseOption> _filtrarCursos(List<CourseOption> origem, String query) {
    final termo = query.trim().toLowerCase();
    if (termo.isEmpty) return List<CourseOption>.from(origem);
    return origem
        .where(
          (curso) =>
              curso.nome.toLowerCase().contains(termo) ||
              curso.id.toLowerCase().contains(termo),
        )
        .toList();
  }

  // Métodos de CRUD de cursos removidos - cursos são pré-cadastrados

  // ---------------------------------------------------------------------------
  // USUÁRIOS ATIVOS
  // ---------------------------------------------------------------------------
  void _onUsuarioAtivosBuscaChange() {
    if (_usuarioAtivosDebounce?.isActive ?? false)
      _usuarioAtivosDebounce!.cancel();
    _usuarioAtivosDebounce = Timer(const Duration(milliseconds: 400), () {
      final novoValor = _buscaUsuariosAtivosController.text.trim();
      if (novoValor == _usuarioBuscaAtivosAtual) return;
      _usuarioBuscaAtivosAtual = novoValor;
      _pagingControllerAtivos.refresh();
    });
  }

  Future<void> _fetchUsuariosAtivosPage(int pageKey) async {
    try {
      // Busca usuários da API SEM filtrar por ativos no serviço
      // Isso permite verificar o tamanho original retornado pela API para paginação correta
      final managedUsersRaw = await UsuarioApi.fetchUsuarios(
        pageKey,
        10,
        _usuarioBuscaAtivosAtual,
        apenasAtivos: null, // Não filtra no serviço, vamos filtrar aqui
      );
      
      // Guarda o tamanho original ANTES do filtro para verificação de última página
      final tamanhoOriginal = managedUsersRaw.length;
      
      // Filtra apenas usuários ativos e que não estão no cache de desativados
      final usuarios = managedUsersRaw
          .where((mu) =>
              mu.active == true && !_usuariosDesativadosCache.contains(mu.id))
          .map((mu) => Usuario(
                id: mu.id,
                nome: mu.nome,
                sobrenome: mu.sobrenome,
                email: mu.email,
                login: mu.login,
                curso: mu.cursoDisplay,
                role: mu.role,
                active: mu.active,
              ))
          .toList();

      // Verifica se é a última página baseado no tamanho ORIGINAL retornado pela API
      // Se a API retornou menos de 10 itens, não há mais páginas
      // IMPORTANTE: Usa o tamanho ANTES do filtro para determinar se há mais páginas
      final isLastPage = tamanhoOriginal < 10;
      
      // Se não há usuários após o filtro mas a API retornou dados, continua buscando
      // Isso evita que usuários sejam perdidos se todos da página estiverem no cache de desativados
      if (usuarios.isEmpty && !isLastPage) {
        // Se não há usuários nesta página mas há mais páginas, busca a próxima
        _fetchUsuariosAtivosPage(pageKey + 1);
        return;
      }
      
      if (isLastPage) {
        _pagingControllerAtivos.appendLastPage(usuarios);
      } else {
        _pagingControllerAtivos.appendPage(usuarios, pageKey + 1);
      }
    } catch (error) {
      _pagingControllerAtivos.error = error;
    }
  }

  // ---------------------------------------------------------------------------
  // USUÁRIOS DESATIVADOS
  // ---------------------------------------------------------------------------
  void _onUsuarioDesativadosBuscaChange() {
    if (_usuarioDesativadosDebounce?.isActive ?? false)
      _usuarioDesativadosDebounce!.cancel();
    _usuarioDesativadosDebounce = Timer(const Duration(milliseconds: 400), () {
      final novoValor = _buscaUsuariosDesativadosController.text.trim();
      if (novoValor == _usuarioBuscaDesativadosAtual) return;
      _usuarioBuscaDesativadosAtual = novoValor;
      _pagingControllerDesativados.refresh();
    });
  }

  Future<void> _fetchUsuariosDesativadosPage(int pageKey) async {
    try {
      // Busca apenas usuários inativos da API usando o parâmetro apenasAtivos: false
      final managedUsers = await UsuarioApi.fetchUsuarios(
        pageKey,
        10,
        _usuarioBuscaDesativadosAtual,
        apenasAtivos: false, // Busca apenas usuários inativos
      );
      // Converte ManagedUser para Usuario
      // A API já deve retornar apenas usuários inativos quando apenasAtivos: false
      // Mas ainda filtra para garantir que apenas inativos apareçam
      final usuariosDaApi = managedUsers
          .where((mu) =>
              mu.active == false) // Filtra apenas inativos para garantir
          .map((mu) => Usuario(
                id: mu.id,
                nome: mu.nome,
                sobrenome: mu.sobrenome,
                email: mu.email,
                login: mu.login,
                curso: mu.cursoDisplay,
                role: mu.role,
                active: mu.active, // Usa o campo active real da API
              ))
          .toList();

      // Adiciona usuários do cache local que ainda não foram retornados pela API
      // (caso de desativações recentes que ainda não foram sincronizadas)
      final usuariosDoCache = _usuariosDesativadosCache
          .where((id) => !usuariosDaApi.any((u) => u.id == id))
          .toList();

      // Se há usuários no cache que não estão na API, busca seus dados
      // Por enquanto, apenas usa os da API para evitar múltiplas chamadas
      final usuarios = usuariosDaApi;

      final isLastPage = usuarios.length < 10;
      if (isLastPage) {
        _pagingControllerDesativados.appendLastPage(usuarios);
      } else {
        _pagingControllerDesativados.appendPage(usuarios, pageKey + 1);
      }
    } catch (error) {
      _pagingControllerDesativados.error = error;
    }
  }

  Future<void> _onAtivarUser(String userId) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Ativar usuário'),
        content: Text(
            'Deseja realmente ativar este usuário? Ele será exibido na lista de usuários ativos.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Ativar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ativando usuário...'),
        duration: Duration(seconds: 1),
      ),
    );

    // Remove o usuário da lista de desativados localmente primeiro
    final itemListDesativados = _pagingControllerDesativados.itemList;
    if (itemListDesativados != null) {
      final itemListAtualizada =
          itemListDesativados.where((u) => u.id != userId).toList();
      _pagingControllerDesativados.itemList = itemListAtualizada;
    }

    try {
      final sucesso =
          await UserService.atualizarUsuario(userId, {'active': true});
      if (!mounted) return;

      if (sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário ativado com sucesso')),
        );

        // Remove do cache de usuários desativados para feedback imediato
        // O cache será limpo após o refresh que buscará o status real da API
        _usuariosDesativadosCache.remove(userId);

        // Recarrega ambas as listas: remove dos desativados e adiciona aos ativos
        // A API agora retorna o campo active correto, então o cache é apenas para feedback imediato
        _pagingControllerAtivos.refresh();
        _pagingControllerDesativados.refresh();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
            const SnackBar(content: Text('Falha ao ativar usuário')));
        // Se falhou, restaura a lista original fazendo refresh
        _pagingControllerDesativados.refresh();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao ativar usuário: $e')));
      _pagingControllerDesativados.refresh();
    }
  }

  Future<void> _onDeleteUser(String userId) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Desativar usuário'),
        content: Text(
            'Deseja realmente desativar este usuário? Ele não será mais exibido na lista.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Desativar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Desativando usuário...'),
        duration: Duration(seconds: 1),
      ),
    );

    // Remove o usuário da lista de ativos localmente primeiro para atualização imediata
    final itemListAtivos = _pagingControllerAtivos.itemList;
    if (itemListAtivos != null) {
      final itemListAtualizada =
          itemListAtivos.where((u) => u.id != userId).toList();
      _pagingControllerAtivos.itemList = itemListAtualizada;
    }

    dynamic resultado = await UsuarioApi.deletarUsuario(userId);
    if (!mounted) return;

    // Verifica se o resultado é um Map
    Map<String, dynamic>? resultadoMap;
    if (resultado is Map<String, dynamic>) {
      resultadoMap = resultado;
    } else {
      // Fallback: se retornou bool (versão antiga), trata como falha
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
          const SnackBar(content: Text('Falha ao desativar usuário')));
      _pagingControllerAtivos.refresh();
      return;
    }

    if (resultadoMap['sucesso'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário desativado com sucesso')),
      );

      // Adiciona ao cache de usuários desativados para feedback imediato
      // O cache será limpo após o refresh que buscará o status real da API
      _usuariosDesativadosCache.add(userId);

      // Recarrega ambas as listas: remove dos ativos e adiciona aos desativados
      // A API agora retorna o campo active correto, então o cache é apenas para feedback imediato
      _pagingControllerAtivos.refresh();
      _pagingControllerDesativados.refresh();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
          const SnackBar(content: Text('Falha ao desativar usuário')));
      // Se falhou, restaura a lista original fazendo refresh
      _pagingControllerAtivos.refresh();
    }
  }

  void _abrirCadastroUsuario() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegisterScreen()),
    ).then((shouldRefresh) {
      if (shouldRefresh == true) {
        _pagingControllerAtivos.refresh();
      }
    });
  }

  void _abrirEdicaoUsuario(Usuario usuario) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ModifyUserApp(usuario: usuario)),
    ).then((shouldRefresh) {
      if (shouldRefresh == true) {
        // Atualiza a lista correspondente (ativa ou desativada)
        if (usuario.active == true) {
          _pagingControllerAtivos.refresh();
        } else {
          _pagingControllerDesativados.refresh();
        }
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
                labelColor: Colors.black87,
                unselectedLabelColor: Colors.grey[600],
                indicatorColor: Theme.of(context).primaryColor,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                tabs: const [
                  Tab(text: 'Cursos'),
                  Tab(text: 'Usuários Ativos'),
                  Tab(text: 'Usuários Desativados'),
                ],
              )
            : null,
      ),
      body: SafeArea(child: _buildBody()),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget? _buildFloatingActionButton() {
    if (!_verificacaoConcluida || !_isAdmin) return null;
    if (_tabController.index == 0) {
      return FloatingActionButton.extended(
        onPressed: _abrirCadastroCurso,
        icon: Icon(Icons.school_outlined),
        label: Text('Novo Curso'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      );
    }
    // Mostra o botão apenas na aba de usuários ativos (índice 1)
    if (_tabController.index == 1) {
      return FloatingActionButton.extended(
        onPressed: _abrirCadastroUsuario,
        icon: Icon(Icons.person_add_alt_1_outlined),
        label: Text('Novo Usuário'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      );
    }
    return null;
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
        _buildUsuariosAtivosTab(),
        _buildUsuariosDesativadosTab(),
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
              fillColor: Theme.of(context).colorScheme.surface,
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
                            child:
                                Center(child: Text('Nenhum curso encontrado.')),
                          ),
                        ],
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        itemCount: _cursosFiltrados.length,
                        itemBuilder: (context, index) {
                          final curso = _cursosFiltrados[index];
                          return _CursoListItem(curso: curso);
                        },
                      ),
          ),
        ),
      ],
    );
  }

  Future<void> _abrirCadastroCurso() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Novo Curso'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Nome do curso',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final nome = controller.text.trim();
                if (nome.isEmpty) return;
                Navigator.of(context).pop(nome);
              },
              child: Text('Criar'),
            ),
          ],
        );
      },
    );

    if (result == null || result.isEmpty) return;
    try {
      setState(() => _operacaoEmAndamento = true);
      final created = await UsuarioApi.criarCurso(result);
      if (!mounted) return;
      if (created != null) {
        setState(() {
          _cursos = [..._cursos, created];
          _cursosFiltrados =
              _filtrarCursos(_cursos, _buscaCursosController.text);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Curso criado: ${created.nome}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Falha ao criar curso')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    } finally {
      if (mounted) setState(() => _operacaoEmAndamento = false);
    }
  }

  // remoção do cadastro de curso (cursos são pré-cadastrados)

  Widget _buildUsuariosAtivosTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _buscaUsuariosAtivosController,
            decoration: InputDecoration(
              hintText: 'Pesquisar usuários ativos...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              _pagingControllerAtivos.refresh();
            },
            child: PagedListView<int, Usuario>(
              pagingController: _pagingControllerAtivos,
              builderDelegate: PagedChildBuilderDelegate<Usuario>(
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
                    Center(child: Text('Nenhum usuário ativo encontrado.')),
                firstPageErrorIndicatorBuilder: (_) =>
                    Center(child: Text('Erro ao carregar usuários ativos.')),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUsuariosDesativadosTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _buscaUsuariosDesativadosController,
            decoration: InputDecoration(
              hintText: 'Pesquisar usuários desativados...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              _pagingControllerDesativados.refresh();
            },
            child: PagedListView<int, Usuario>(
              pagingController: _pagingControllerDesativados,
              builderDelegate: PagedChildBuilderDelegate<Usuario>(
                itemBuilder: (context, usuario, index) => _UsuarioListItem(
                  usuario: usuario,
                  onDelete: () =>
                      _onAtivarUser(usuario.id), // Ativa usuários desativados
                  onModify: () => _abrirEdicaoUsuario(usuario),
                ),
                firstPageProgressIndicatorBuilder: (_) =>
                    Center(child: CircularProgressIndicator()),
                newPageProgressIndicatorBuilder: (_) =>
                    Center(child: CircularProgressIndicator()),
                noItemsFoundIndicatorBuilder: (_) => Center(
                    child: Text('Nenhum usuário desativado encontrado.')),
                firstPageErrorIndicatorBuilder: (_) => Center(
                    child: Text('Erro ao carregar usuários desativados.')),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CursoListItem extends StatelessWidget {
  const _CursoListItem({required this.curso});

  final CourseOption curso;

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
        title: Text(curso.nome, style: TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('ID: ${curso.id}'),
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

  final Usuario usuario;
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
                        foregroundColor: Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: onDelete,
                      icon: Icon(
                        usuario.active
                            ? Icons.delete_outline
                            : Icons.check_circle_outline,
                        size: 18,
                      ),
                      label: Text(usuario.active ? 'Desativar' : 'Ativar'),
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
