import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

// Seus imports, todos corretos.
import 'package:flutter_application_1/screens/event_register.dart';
import 'package:flutter_application_1/screens/user_register.dart';
import 'package:flutter_application_1/screens/perfil.dart';
import 'package:flutter_application_1/screens/search.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:flutter_application_1/models/evento.dart';
import 'package:flutter_application_1/widgets/event_card.dart';
import 'package:flutter_application_1/widgets/branded_header.dart';
import 'package:flutter_application_1/widgets/state_views.dart';
import 'package:flutter_application_1/config/app_theme.dart';

// Modelo Evento agora em lib/models/evento.dart

// Classe Principal da Home (sem alterações)
class EventosPage extends StatefulWidget {
  const EventosPage({super.key});

  @override
  _EventosPageState createState() => _EventosPageState();
}

class _EventosPageState extends State<EventosPage> {
  // ... (todo o código de _EventosPageState permanece o mesmo)
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true));
  int _selectedIndex = 0;
  String? _role;
  List<Widget> _pages = const [];

  @override
  void initState() {
    super.initState();
    _loadRoleAndSetupPages();
  }

  Future<void> _loadRoleAndSetupPages() async {
    try {
      final role = await _storage.read(key: 'role');
      if (!mounted) return;

      setState(() {
        _role = role ?? 'user';
        final bool isAdmin = _isAdmin;

        _pages = [
          const FeedPage(),
          const EVRegister(),
          if (isAdmin) const CadastroUsuarioPage(),
          const PerfilPage(),
        ];
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _role = 'user';
        _pages = [const FeedPage(), const EVRegister(), const PerfilPage()];
      });
    }
  }

  bool get _isAdmin => (_role ?? '').toLowerCase() == 'admin';

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_role == null || _pages.isEmpty) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
          ),
        ),
      );
    }
    final bool isAdmin = _isAdmin;
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey[600],
        showUnselectedLabels: false,
        showSelectedLabels: false,
        backgroundColor: Colors.white,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.celebration_outlined),
            activeIcon: Icon(Icons.celebration),
            label: 'Eventos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'Cadastrar',
          ),
          if (isAdmin)
            BottomNavigationBarItem(
              icon: Icon(Icons.school_outlined),
              activeIcon: Icon(Icons.school),
              label: 'Cursos',
            ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

// --- TELA DO FEED DE EVENTOS, AGORA CONECTADA À API ---
/// Lista paginada de eventos usando EventosApi + infinite_scroll_pagination.
class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  static const int _pageSize = 10;
  final PagingController<int, Evento> _pagingController = PagingController(
    firstPageKey: 0,
  );

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  /// Busca uma página de eventos na API e atualiza o PagingController.
  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = await EventosApi.fetchEventos(pageKey, _pageSize);
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BrandedScaffold(
      header: BrandedHeader(
        title: 'Eventos',
        subtitle: 'Próximos a você',
        actions: [
          IconButton(
            tooltip: 'Buscar eventos',
            icon: const Icon(Icons.search, color: AppColors.onPrimary),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SearchPage()),
            ),
          ),
          IconButton(
            tooltip: 'Notificações',
            icon: const Icon(Icons.notifications_none, color: AppColors.onPrimary),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => Future.sync(() => _pagingController.refresh()),
        child: PagedListView<int, Evento>(
          pagingController: _pagingController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          physics: const AlwaysScrollableScrollPhysics(),
          builderDelegate: PagedChildBuilderDelegate<Evento>(
            itemBuilder: (context, evento, index) => EventoCard(
              evento: evento,
              onEventUpdated: _pagingController.refresh,
            ),
            firstPageProgressIndicatorBuilder: (_) => const LoadingView(),
            newPageProgressIndicatorBuilder: (_) => const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
            noItemsFoundIndicatorBuilder: (_) => const EmptyView(
              icon: Icons.event_busy_outlined,
              title: 'Nenhum evento encontrado.',
            ),
            firstPageErrorIndicatorBuilder: (_) => ErrorView(
              message: 'Erro ao carregar eventos.',
              onRetry: _pagingController.refresh,
            ),
          ),
        ),
      ),
    );
  }
}
