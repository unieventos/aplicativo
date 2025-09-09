import 'dart:async';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';

// Imports necessários
import 'package:flutter_application_1/models/evento.dart'; // Modelo Evento centralizado
import 'package:flutter_application_1/api_service.dart'; // Para a classe EventosApi

// --- TELA DE BUSCA DE EVENTOS FINALIZADA E CONECTADA À API ---
class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  static const _pageSize = 10;
  final PagingController<int, Evento> _pagingController = PagingController(firstPageKey: 0);
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Adiciona o listener para o PagingController, que chama a API
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey, _searchController.text);
    });

    // Adiciona o listener para o campo de busca com debounce
    _searchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        _pagingController.refresh();
      });
    });
  }

  // Função que busca os dados da API
  Future<void> _fetchPage(int pageKey, String query) async {
    try {
      final newItems = await EventosApi.fetchEventos(pageKey, _pageSize, search: query);
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
  
  // A lógica de seleção e de mostrar ações permanece a mesma
  final Set<Evento> _eventosSelecionados = Set<Evento>();
  
  void _onEventoSelecionado(Evento evento, bool selecionado) {
    setState(() {
      if (selecionado) {
        _eventosSelecionados.add(evento);
      } else {
        _eventosSelecionados.remove(evento);
      }
    });
  }
  
  void _mostrarAcoes() { /* ... sua função _mostrarAcoes ... */ }

  @override
  void dispose() {
    _pagingController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(hintText: 'Buscar por título ou curso...', border: InputBorder.none, hintStyle: TextStyle(color: Colors.white70)),
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (_eventosSelecionados.isNotEmpty)
            IconButton(icon: Icon(Icons.send_outlined), tooltip: "Ações", onPressed: _mostrarAcoes),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => Future.sync(() => _pagingController.refresh()),
        child: PagedListView<int, Evento>(
          pagingController: _pagingController,
          padding: EdgeInsets.all(8),
          builderDelegate: PagedChildBuilderDelegate<Evento>(
            itemBuilder: (context, evento, index) {
              final isSelected = _eventosSelecionados.contains(evento);
              return _EventListItem(
                evento: evento,
                isSelected: isSelected,
                onSelected: (selected) => _onEventoSelecionado(evento, selected),
              );
            },
            // Widgets para os diferentes estados da lista
            firstPageProgressIndicatorBuilder: (_) => Center(child: CircularProgressIndicator()),
            newPageProgressIndicatorBuilder: (_) => Padding(padding: const EdgeInsets.all(16.0), child: Center(child: CircularProgressIndicator())),
            noItemsFoundIndicatorBuilder: (_) => Center(child: Text("Nenhum evento encontrado.")),
            firstPageErrorIndicatorBuilder: (_) => Center(child: Text("Erro ao buscar eventos.")),
          ),
        ),
      ),
    );
  }
}


// --- WIDGET DO ITEM DA LISTA (sem alterações) ---
class _EventListItem extends StatelessWidget {
  final Evento evento;
  final bool isSelected;
  final ValueChanged<bool> onSelected;

  const _EventListItem({ required this.evento, required this.isSelected, required this.onSelected });

  @override
  Widget build(BuildContext context) {
    // O design do seu card permanece o mesmo
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.white,
      child: ExpansionTile(
        leading: Checkbox(value: isSelected, onChanged: (value) => onSelected(value!), activeColor: Theme.of(context).primaryColor),
        title: Text(evento.titulo, style: TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(evento.cursoAutor, style: TextStyle(color: Colors.grey[600])),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                    errorBuilder: (context, error, stackTrace) => Container(height: 100, color: Colors.grey[200], child: Icon(Icons.image_not_supported_outlined, color: Colors.grey)),
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
