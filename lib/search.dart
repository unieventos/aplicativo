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

  @override
  void dispose() {
    _searchController.dispose();
    _pagingController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Buscar eventos...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              _pagingController.refresh();
            },
          ),
        ],
      ),
      body: PagedListView<int, Evento>(
        pagingController: _pagingController,
        padding: EdgeInsets.all(8),
        builderDelegate: PagedChildBuilderDelegate<Evento>(
          itemBuilder: (context, evento, index) => EventoCard(evento: evento),
          firstPageProgressIndicatorBuilder: (_) => Center(child: CircularProgressIndicator()),
          newPageProgressIndicatorBuilder: (_) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          ),
          noItemsFoundIndicatorBuilder: (_) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  "Nenhum evento encontrado.",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  "Tente ajustar sua busca.",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          firstPageErrorIndicatorBuilder: (_) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  "Erro ao carregar eventos.",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => _pagingController.refresh(),
                  child: Text('Tentar novamente'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- CARD DE EVENTO PARA BUSCA ---
class EventoCard extends StatelessWidget {
  const EventoCard({Key? key, required this.evento}) : super(key: key);

  final Evento evento;

  String _periodo() {
    final formatter = DateFormat('d MMM, yyyy', 'pt_BR');
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
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Icon(Icons.event, color: Colors.white),
        ),
        title: Text(
          evento.nome,
          style: TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _periodo(),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            if (evento.categoria != null && evento.categoria!.isNotEmpty)
              Text(
                evento.categoria!,
                style: TextStyle(fontSize: 12, color: Theme.of(context).primaryColor),
              ),
          ],
        ),
        trailing: Text(
          '${evento.participantes} participantes',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        onTap: () {
          // Aqui você pode navegar para uma tela de detalhes do evento
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Detalhes do evento: ${evento.nome}')),
          );
        },
      ),
    );
  }
}