import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';

// Seus imports, todos corretos.
import 'package:flutter_application_1/eventRegister.dart';
import 'package:flutter_application_1/UserRegister.dart';
import 'package:flutter_application_1/perfil.dart';
import 'package:flutter_application_1/search.dart';
import 'package:flutter_application_1/login.dart';
import 'package:flutter_application_1/api_service.dart';
import 'package:flutter_application_1/models/evento.dart';

// Modelo Evento agora em lib/models/evento.dart

// Classe Principal da Home (sem alterações)
class EventosPage extends StatefulWidget {
  @override
  _EventosPageState createState() => _EventosPageState();
}

class _EventosPageState extends State<EventosPage> {
  // ... (todo o código de _EventosPageState permanece o mesmo)
  final _storage = FlutterSecureStorage();
  int _selectedIndex = 0;
  String? _role;
  List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _loadRoleAndSetupPages();
  }

  Future<void> _loadRoleAndSetupPages() async {
    final role = await _storage.read(key: 'role');
    setState(() {
      _role = role ?? 'user';
      final bool isAdmin = _role?.toLowerCase() == 'admin';

      _pages = [
        FeedPage(),
        EVRegister(),
        if (isAdmin) CadastroUsuarioPage(),
        PerfilPage(),
      ];
    });
  }

  void _onItemTapped(int index) {
    setState(() { _selectedIndex = index; });
  }

  @override
  Widget build(BuildContext context) {
    if (_role == null || _pages.isEmpty) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final bool isAdmin = _role?.toLowerCase() == 'admin';
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey[600],
        showUnselectedLabels: false,
        showSelectedLabels: false,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.celebration_outlined), activeIcon: Icon(Icons.celebration), label: 'Eventos'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), activeIcon: Icon(Icons.add_circle), label: 'Cadastrar'),
          if (isAdmin) BottomNavigationBarItem(icon: Icon(Icons.group_outlined), activeIcon: Icon(Icons.group), label: 'Usuários'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

// --- TELA DO FEED DE EVENTOS, AGORA CONECTADA À API ---
class FeedPage extends StatefulWidget {
  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  static const _pageSize = 10;
  final PagingController<int, Evento> _pagingController = PagingController(firstPageKey: 0);

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

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
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text("Próximos Eventos", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: Icon(Icons.search), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SearchPage()))),
          IconButton(icon: Icon(Icons.notifications_none), onPressed: () {}),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => Future.sync(() => _pagingController.refresh()),
        child: PagedListView<int, Evento>(
          pagingController: _pagingController,
          padding: EdgeInsets.all(8),
          builderDelegate: PagedChildBuilderDelegate<Evento>(
            itemBuilder: (context, evento, index) => EventoCard(evento: evento),
            firstPageProgressIndicatorBuilder: (_) => Center(child: CircularProgressIndicator()),
            newPageProgressIndicatorBuilder: (_) => Padding(padding: const EdgeInsets.all(16.0), child: Center(child: CircularProgressIndicator())),
            noItemsFoundIndicatorBuilder: (_) => Center(child: Text("Nenhum evento encontrado.")),
            firstPageErrorIndicatorBuilder: (_) => Center(child: Text("Erro ao carregar eventos.")),
          ),
        ),
      ),
    );
  }
}

// --- CARD DE EVENTO (sem alterações) ---
class EventoCard extends StatelessWidget {
  final Evento evento;
  const EventoCard({Key? key, required this.evento}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ... (O código do seu EventoCard permanece exatamente o mesmo)
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.15),
      child: Column( /* ... seu conteúdo do card ... */ ),
    );
  }
}


// API de eventos centralizada em lib/api_service.dart
