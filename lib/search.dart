import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Importa a classe Evento CORRETA do seu arquivo home.dart
import 'package:flutter_application_1/home.dart';

// --- TELA DE BUSCA DE EVENTOS CORRIGIDA E REATORADA ---
class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // CORREÇÃO: Usando o modelo de dados 'Evento' consistente com o home.dart
  final List<Evento> _todosEventos = [
    Evento(titulo: "Semana da Computação", cursoAutor: "Computação", autor: 'Prof. Ricardo', autorAvatarUrl: '', data: DateTime.now(), imagemUrl: 'https://images.unsplash.com/photo-1540575467063-178a50c2df87', participantes: 250),
    Evento(titulo: "Workshop de Design UI/UX", cursoAutor: "Design", autor: 'Profa. Ana', autorAvatarUrl: '', data: DateTime.now(), imagemUrl: 'https://images.unsplash.com/photo-1558690623-3923c242a13b', participantes: 80),
    Evento(titulo: "Palestra sobre IA Generativa", cursoAutor: "Tecnologia", autor: 'Dr. Silva', autorAvatarUrl: '', data: DateTime.now(), imagemUrl: 'https://images.unsplash.com/photo-1677756119517-756a188d2d94', participantes: 150),
    Evento(titulo: "Maratona de Programação", cursoAutor: "Competição", autor: 'Coordenação', autorAvatarUrl: '', data: DateTime.now(), imagemUrl: 'https://images.unsplash.com/photo-1579820010410-c10411aaaa88', participantes: 120),
  ];

  List<Evento> _eventosFiltrados = [];
  final Set<Evento> _eventosSelecionados = Set<Evento>();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _eventosFiltrados = _todosEventos;
    _searchController.addListener(_filtrarEventos);
  }

  // Filtra usando os campos corretos do modelo 'Evento'
  void _filtrarEventos() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _eventosFiltrados = _todosEventos.where((evento) {
        return evento.titulo.toLowerCase().contains(query) || 
               evento.cursoAutor.toLowerCase().contains(query); // CORREÇÃO: 'tipo' -> 'cursoAutor'
      }).toList();
    });
  }
  
  void _onEventoSelecionado(Evento evento, bool selecionado) {
    setState(() {
      if (selecionado) {
        _eventosSelecionados.add(evento);
      } else {
        _eventosSelecionados.remove(evento);
      }
    });
  }
  
  void _mostrarAcoes() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.download_outlined),
              title: Text('Baixar Relatório (${_eventosSelecionados.length})'),
              onTap: () { /* Lógica de download */ Navigator.pop(context); },
            ),
            ListTile(
              leading: Icon(Icons.email_outlined),
              title: Text('Enviar por E-mail'),
              onTap: () { /* Lógica de envio */ Navigator.pop(context); },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Buscar por título ou curso...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (_eventosSelecionados.isNotEmpty)
            IconButton(
              icon: Icon(Icons.send_outlined),
              tooltip: "Ações",
              onPressed: _mostrarAcoes,
            ),
        ],
      ),
      body: _eventosFiltrados.isEmpty
          ? Center(child: Text("Nenhum evento encontrado."))
          : ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: _eventosFiltrados.length,
              itemBuilder: (context, index) {
                final evento = _eventosFiltrados[index];
                final isSelected = _eventosSelecionados.contains(evento);
                return _EventListItem(
                  evento: evento,
                  isSelected: isSelected,
                  onSelected: (selected) => _onEventoSelecionado(evento, selected),
                );
              },
            ),
    );
  }
}

class _EventListItem extends StatelessWidget {
  final Evento evento;
  final bool isSelected;
  final ValueChanged<bool> onSelected;

  const _EventListItem({ required this.evento, required this.isSelected, required this.onSelected });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.white,
      child: ExpansionTile(
        leading: Checkbox(
          value: isSelected,
          onChanged: (value) => onSelected(value!),
          activeColor: Theme.of(context).primaryColor,
        ),
        title: Text(evento.titulo, style: TextStyle(fontWeight: FontWeight.w600)),
        // CORREÇÃO: 'tipo' -> 'cursoAutor'
        subtitle: Text(evento.cursoAutor, style: TextStyle(color: Colors.grey[600])),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Adicionando informações extras que já temos no modelo
                Text('Organizado por: ${evento.autor}'),
                SizedBox(height: 4),
                Text('Data: ${DateFormat('d MMM, yyyy', 'pt_BR').format(evento.data)}'),
                SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    evento.imagemUrl,
                    width: double.infinity,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 100,
                      color: Colors.grey[200],
                      child: Icon(Icons.image_not_supported_outlined, color: Colors.grey),
                    ),
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