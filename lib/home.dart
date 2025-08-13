import 'package:flutter/material.dart';
// --- CORREÇÃO 1: IMPORTS CORRIGIDOS ---
// Os caminhos dos pacotes foram corrigidos para o formato padrão 'package:...'.
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

// Seus imports, todos corretos.
import 'package:flutter_application_1/eventRegister.dart';
import 'package:flutter_application_1/UserRegister.dart';
import 'package:flutter_application_1/perfil.dart';
import 'package:flutter_application_1/search.dart';
import 'package:flutter_application_1/login.dart';

// Modelo de Dados (sem alterações)
class Evento {
  final String titulo, autor, cursoAutor, autorAvatarUrl, imagemUrl;
  final DateTime data;
  final int participantes;

  Evento({
    required this.titulo,
    required this.autor,
    required this.cursoAutor,
    required this.autorAvatarUrl,
    required this.imagemUrl,
    required this.data,
    required this.participantes,
  });
}

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
      return Scaffold(body: Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor)));
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
          BottomNavigationBarItem(icon: Icon(Icons.celebration_outlined), activeIcon: Icon(Icons.celebration), label: 'Eventos'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), activeIcon: Icon(Icons.add_circle), label: 'Cadastrar'),
          if (isAdmin)
            BottomNavigationBarItem(icon: Icon(Icons.group_outlined), activeIcon: Icon(Icons.group), label: 'Usuários'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

// --- TELA DO FEED DE EVENTOS (com correção nas imagens) ---
class FeedPage extends StatelessWidget {
  
  // --- CORREÇÃO 2: URLs DAS IMAGENS DE EXEMPLO TROCADAS ---
  // Trocamos 'pravatar.cc' por 'picsum.photos', que funciona melhor na web.
  final List<Evento> _listaEventos = [
    Evento(titulo: "Semana da Computação 2024", autor: "Prof. Ricardo Silva", cursoAutor: "Ciência da Computação", autorAvatarUrl: 'https://picsum.photos/id/1005/100/100', imagemUrl: 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?auto=format&fit=crop&q=80&w=2070', data: DateTime(2024, 10, 20), participantes: 250),
    Evento(titulo: "Palestra: IA no Direito", autor: "Profa. Ana Furtado", cursoAutor: "Direito", autorAvatarUrl: 'https://picsum.photos/id/1027/100/100', imagemUrl: 'https://images.unsplash.com/photo-1511578314322-379afb476865?auto=format&fit=crop&q=80&w=2070', data: DateTime(2024, 11, 05), participantes: 120),
  ];

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
      body: ListView.builder(
        padding: EdgeInsets.all(8),
        itemCount: _listaEventos.length,
        itemBuilder: (context, index) {
          return EventoCard(evento: _listaEventos[index]);
        },
      ),
    );
  }
}

// --- CARD DE EVENTO REUTILIZÁVEL (sem alterações) ---
class EventoCard extends StatelessWidget {
  final Evento evento;
  const EventoCard({Key? key, required this.evento}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            child: CachedNetworkImage(
              imageUrl: evento.imagemUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(height: 200, color: Colors.grey[200]),
              errorWidget: (context, url, error) => Container(height: 200, color: Colors.grey[200], child: Icon(Icons.error)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(evento.titulo, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey[700]),
                    SizedBox(width: 6),
                    Text(DateFormat('d MMM, yyyy', 'pt_BR').format(evento.data), style: TextStyle(fontSize: 14, color: Colors.grey[800])),
                    SizedBox(width: 20),
                    Icon(Icons.group_outlined, size: 16, color: Colors.grey[700]),
                    SizedBox(width: 6),
                    Text("${evento.participantes} participantes", style: TextStyle(fontSize: 14, color: Colors.grey[800])),
                  ],
                ),
                Divider(height: 24),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(evento.autorAvatarUrl),
                      radius: 20,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(evento.autor, style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(evento.cursoAutor, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        ],
                      ),
                    ),
                    if (true) 
                      IconButton(
                        icon: Icon(Icons.assessment_outlined, color: Theme.of(context).primaryColor),
                        tooltip: "Ver Relatório do Evento",
                        onPressed: () {},
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