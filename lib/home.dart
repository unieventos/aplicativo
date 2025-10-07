import 'package:flutter/material.dart';
// --- CORREÇÃO 1: IMPORTS CORRIGIDOS ---
// Os caminhos dos pacotes foram corrigidos para o formato padrão 'package:...'.
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

// Seus imports, todos corretos.
import 'package:flutter_application_1/eventRegister.dart';
import 'package:flutter_application_1/event_service.dart';
import 'package:flutter_application_1/UserRegister.dart';
import 'package:flutter_application_1/perfil.dart';
import 'package:flutter_application_1/search.dart';

// Classe Principal da Home (com a lógica de permissão correta)
class EventosPage extends StatefulWidget {
  @override
  _EventosPageState createState() => _EventosPageState();
}

class _EventosPageState extends State<EventosPage> {
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
        EVRegister(), // Visível para todos
        if (isAdmin) CadastroUsuarioPage(), // Apenas para admin
        PerfilPage(),
      ];
    });
  }

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
                  color: Theme.of(context).primaryColor)));
    }

    final bool isAdmin = _role?.toLowerCase() == 'admin';

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
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
          BottomNavigationBarItem(
              icon: Icon(Icons.celebration_outlined),
              activeIcon: Icon(Icons.celebration),
              label: 'Eventos'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline),
              activeIcon: Icon(Icons.add_circle),
              label: 'Cadastrar'),
          if (isAdmin)
            BottomNavigationBarItem(
                icon: Icon(Icons.school_outlined),
                activeIcon: Icon(Icons.school),
                label: 'Cursos'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Perfil'),
        ],
      ),
    );
  }
}

// --- TELA DO FEED DE EVENTOS ---
class FeedPage extends StatefulWidget {
  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final DateFormat _formatter = DateFormat('d MMM, yyyy', 'pt_BR');
  bool _isLoading = false;
  String? _erro;
  List<EventFeedItem> _eventos = [];

  @override
  void initState() {
    super.initState();
    _carregarEventos();
  }

  Future<void> _carregarEventos({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
        _erro = null;
      });
    }
    try {
      final eventos = await EventService.listarEventos();
      if (!mounted) return;
      setState(() {
        _eventos = eventos;
        _erro = null;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _eventos = [];
        _erro = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() => _carregarEventos(silent: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'Próximos Eventos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SearchPage()),
            ),
          ),
          IconButton(icon: Icon(Icons.notifications_none), onPressed: () {}),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading && _eventos.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      );
    }

    if (_erro != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        children: [
          Icon(Icons.wifi_off, size: 64, color: Colors.redAccent),
          SizedBox(height: 16),
          Text(
            'Não foi possível carregar os eventos.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            _erro!,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[700]),
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _carregarEventos,
            icon: Icon(Icons.refresh),
            label: Text('Tentar novamente'),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 48),
            ),
          ),
        ],
      );
    }

    if (_eventos.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        children: [
          Icon(
            Icons.event_available_outlined,
            size: 64,
            color: Theme.of(context).primaryColor,
          ),
          SizedBox(height: 16),
          Text(
            'Nenhum evento cadastrado ainda.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Quando novos eventos forem publicados, eles aparecerão aqui.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[700]),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemBuilder: (context, index) =>
          EventoCard(evento: _eventos[index], formatter: _formatter),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: _eventos.length,
    );
  }
}

class EventoCard extends StatelessWidget {
  const EventoCard({Key? key, required this.evento, required this.formatter})
      : super(key: key);

  final EventFeedItem evento;
  final DateFormat formatter;

  String _periodo() {
    final inicio = evento.inicio;
    final fim = evento.fim;
    if (inicio != null && fim != null) {
      if (inicio.isAtSameMomentAs(fim)) {
        return formatter.format(inicio);
      }
      return '${formatter.format(inicio)} - ${formatter.format(fim)}';
    }
    if (inicio != null) return formatter.format(inicio);
    if (fim != null) return formatter.format(fim);
    return 'Data a definir';
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = evento.imagemUrl;
    final categoria = evento.categoria;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            child: imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 200,
                      color: Colors.grey[200],
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: Icon(Icons.image_not_supported_outlined,
                          color: Colors.grey[600]),
                    ),
                  )
                : Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: Icon(Icons.event_outlined,
                        size: 48, color: Colors.grey[600]),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  evento.nome,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 16, color: Colors.grey[700]),
                    SizedBox(width: 6),
                    Text(
                      _periodo(),
                      style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.group_outlined,
                        size: 16, color: Colors.grey[700]),
                    SizedBox(width: 6),
                    Text(
                      evento.participantes > 0
                          ? '${evento.participantes} participantes'
                          : 'Seja o primeiro a confirmar presença',
                      style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                    ),
                  ],
                ),
                if (categoria != null && categoria.isNotEmpty) ...[
                  SizedBox(height: 12),
                  Chip(
                    label: Text(categoria),
                    backgroundColor:
                        Theme.of(context).primaryColor.withOpacity(0.1),
                    labelStyle: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
                SizedBox(height: 12),
                Text(
                  evento.descricao,
                  style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (evento.criador != null && evento.criador!.isNotEmpty) ...[
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.person_outline,
                          size: 16, color: Colors.grey[600]),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Criado por ${evento.criador}',
                          style: TextStyle(color: Colors.grey[600]),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
