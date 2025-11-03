import 'dart:async';

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

// Imports necessários
import 'package:flutter_application_1/models/evento.dart'; // Modelo Evento centralizado
import 'package:flutter_application_1/api_service.dart'; // Para a classe EventosApi
import 'package:flutter_application_1/widgets/event_card.dart';

// --- TELA DE BUSCA DE EVENTOS FINALIZADA E CONECTADA À API ---
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  static const int _pageSize = 10;
  final PagingController<int, Evento> _pagingController = PagingController(
    firstPageKey: 0,
  );
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
      if (!mounted) return;
      setState(() {});
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        _pagingController.refresh();
      });
    });
  }

  // Função que busca os dados da API
  Future<void> _fetchPage(int pageKey, String query) async {
    try {
      final newItems = await EventosApi.fetchEventos(
        pageKey,
        _pageSize,
        search: query,
      );
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
        title: const Text('Buscar eventos'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(76),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Digite o nome do evento ou categoria',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Limpar busca',
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          _pagingController.refresh();
                        },
                      ),
              ),
              onSubmitted: (_) => _pagingController.refresh(),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => Future.sync(_pagingController.refresh),
        child: PagedListView<int, Evento>(
          pagingController: _pagingController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          physics: const AlwaysScrollableScrollPhysics(),
          builderDelegate: PagedChildBuilderDelegate<Evento>(
            itemBuilder: (context, evento, index) => EventoCard(
              evento: evento,
              layout: EventoCardLayout.list,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Evento: ${evento.nome}')),
                );
              },
            ),
            firstPageProgressIndicatorBuilder: (_) =>
                const Center(child: CircularProgressIndicator()),
            newPageProgressIndicatorBuilder: (_) => const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
            noItemsFoundIndicatorBuilder: (_) => const _SearchEmptyState(),
            firstPageErrorIndicatorBuilder: (_) =>
                _SearchErrorState(onRetry: _pagingController.refresh),
          ),
        ),
      ),
    );
  }
}

class _SearchEmptyState extends StatelessWidget {
  const _SearchEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Nenhum evento encontrado',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Tente usar outra palavra-chave ou filtros diferentes.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchErrorState extends StatelessWidget {
  const _SearchErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            const Text(
              'Erro ao carregar eventos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Verifique sua conexão ou tente novamente em instantes.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
