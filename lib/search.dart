import 'dart:async';

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

// Imports necessários
import 'package:flutter_application_1/models/evento.dart'; // Modelo Evento centralizado
import 'package:flutter_application_1/models/course_option.dart';
import 'package:flutter_application_1/api_service.dart'; // Para a classe EventosApi e UsuarioApi
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

  // Filtros de Data
  String _selectedDateFilter = 'Todas as datas';
  DateTimeRange? _customDateRange;

  CourseOption? _selectedCourse;
  List<CourseOption> _cursos = [];

  // Constantes de período
  static const List<String> _dateFilters = [
    'Todas as datas',
    'Esta semana',
    'Este mês',
    'Último ano',
    'Personalizado...'
  ];

  // Mock list
  final List<Evento> _mockEventos = [
    Evento(
      id: '1',
      titulo: 'evento de ciências da computação',
      descricao: '',
      autor: '',
      criador: '',
      cursoAutor: 'Ciência da Computação',
      autorAvatarUrl: '',
      imagemUrl: '',
      data: DateTime(2025, 9, 18),
      inicio: DateTime(2025, 9, 18, 0, 0),
      fim: DateTime(2025, 9, 30, 0, 0),
      categoria: 'Geral',
      participantes: 0,
    ),
    Evento(
      id: '2',
      titulo: 'evento',
      descricao: '',
      autor: '',
      criador: '',
      cursoAutor: 'Design',
      autorAvatarUrl: '',
      imagemUrl: '',
      data: DateTime(2025, 9, 19),
      inicio: DateTime(2025, 9, 19, 0, 0),
      fim: DateTime(2025, 9, 30, 0, 0),
      categoria: 'Geral',
      participantes: 0,
    ),
    Evento(
      id: '3',
      titulo: 'teste',
      descricao: '',
      autor: '',
      criador: '',
      cursoAutor: 'Odontologia',
      autorAvatarUrl: '',
      imagemUrl: '',
      data: DateTime(2025, 9, 19),
      inicio: DateTime(2025, 9, 19, 0, 0),
      fim: DateTime(2025, 9, 19, 0, 0),
      categoria: 'Geral',
      participantes: 0,
    ),
    Evento(
      id: '4',
      titulo: 'programação',
      descricao: '',
      autor: '',
      criador: '',
      cursoAutor: 'Ciência da Computação',
      autorAvatarUrl: '',
      imagemUrl: '',
      data: DateTime(2025, 9, 19),
      inicio: DateTime(2025, 9, 19, 0, 0),
      fim: DateTime(2025, 9, 30, 0, 0),
      categoria: 'Geral',
      participantes: 0,
    ),
    Evento(
      id: '5',
      titulo: 'evento teste 1122',
      descricao: '',
      autor: '',
      criador: '',
      cursoAutor: 'História',
      autorAvatarUrl: '',
      imagemUrl: '',
      data: DateTime(2025, 9, 19),
      inicio: DateTime(2025, 9, 19, 0, 0),
      fim: DateTime(2025, 9, 26, 0, 0),
      categoria: 'Geral',
      participantes: 0,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _carregarCursos();
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

  Future<void> _carregarCursos() async {
    try {
      final cursos = await UsuarioApi.listarCursos();
      if (mounted) {
        setState(() {
          _cursos = cursos;
        });
      }
    } catch (e) {
      // Falha ao carregar cursos, deixa vazio
    }
  }

  // Função que busca os dados mockados
  Future<void> _fetchPage(int pageKey, String query) async {
    try {
      // Simula tempo de rede
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Realiza a filtragem inteiramente mockada
      List<Evento> filtered = _mockEventos.where((evento) {
        // Filtro por texto na query (nome e categoria)
        final bool matchesQuery = query.trim().isEmpty ||
            evento.titulo.toLowerCase().contains(query.trim().toLowerCase()) ||
            evento.categoria.toLowerCase().contains(query.trim().toLowerCase());
            
        // Filtro por período de data
        bool matchesDate = true;
        final agora = DateTime.now();

        if (_selectedDateFilter != 'Todas as datas') {
          if (_selectedDateFilter == 'Esta semana') {
            final inicioSemana = agora.subtract(Duration(days: agora.weekday - 1));
            final fimSemana = inicioSemana.add(const Duration(days: 6, hours: 23, minutes: 59));
            matchesDate = evento.data.isAfter(inicioSemana.subtract(const Duration(days: 1))) && 
                          evento.data.isBefore(fimSemana.add(const Duration(days: 1)));
          } else if (_selectedDateFilter == 'Este mês') {
            matchesDate = evento.data.year == agora.year && evento.data.month == agora.month;
          } else if (_selectedDateFilter == 'Último ano') {
            final umAnoAtras = DateTime(agora.year - 1, agora.month, agora.day);
            matchesDate = evento.data.isAfter(umAnoAtras) && evento.data.isBefore(agora.add(const Duration(days: 1)));
          } else if (_selectedDateFilter == 'Personalizado...' && _customDateRange != null) {
            final inicio = _customDateRange!.start;
            // Inclui o fim do dia selecionado
            final fim = _customDateRange!.end.add(const Duration(hours: 23, minutes: 59, seconds: 59));
            matchesDate = evento.data.isAfter(inicio.subtract(const Duration(seconds: 1))) && 
                          evento.data.isBefore(fim.add(const Duration(seconds: 1)));
          }
        }

        // Filtro por curso
        bool matchesCourse = true;
        if (_selectedCourse != null) {
           matchesCourse = evento.cursoAutor == _selectedCourse!.nome;
        }

        return matchesQuery && matchesDate && matchesCourse;
      }).toList();

      // Paginando localmente a lista 
      final isLastPage = (pageKey * _pageSize + _pageSize) >= filtered.length;
      final newItems = filtered.skip(pageKey * _pageSize).take(_pageSize).toList();
      
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
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.filter_list),
                if (_selectedDateFilter != 'Todas as datas' || _selectedCourse != null)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 10,
                        minHeight: 10,
                      ),
                    ),
                  )
              ],
            ),
            onPressed: () => _showFilterBottomSheet(context),
            tooltip: 'Filtros',
          ),
        ],
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

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filtros da Busca',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Seleção de Data
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Período',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedDateFilter,
                    isExpanded: true,
                    items: _dateFilters.map((String filter) {
                      return DropdownMenuItem<String>(
                        value: filter,
                        child: Text(filter),
                      );
                    }).toList(),
                    onChanged: (String? newValue) async {
                      if (newValue == 'Personalizado...') {
                        final pickedRange = await showDateRangePicker(
                          context: context,
                          initialDateRange: _customDateRange ?? DateTimeRange(
                            start: DateTime.now(),
                            end: DateTime.now().add(const Duration(days: 7)),
                          ),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                // Ajustes de tema do picker se necessário
                              ),
                              child: child!,
                            );
                          },
                        );

                        if (pickedRange != null) {
                          setModalState(() {
                            _selectedDateFilter = newValue!;
                            _customDateRange = pickedRange;
                          });
                        } else if (_selectedDateFilter != 'Personalizado...') {
                          // Se cancelou, volta pro filtro anterior se não era personalizado,
                          // se já era, mantém
                        } else if (_customDateRange == null) {
                           // Cancelou na primeira vez que tentou personalizar
                           setModalState(() {
                            _selectedDateFilter = 'Todas as datas';
                           });
                        }
                      } else {
                        setModalState(() {
                          _selectedDateFilter = newValue ?? 'Todas as datas';
                        });
                      }
                    },
                  ),
                  if (_selectedDateFilter == 'Personalizado...' && _customDateRange != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                      child: Text(
                        'De ${_customDateRange!.start.day.toString().padLeft(2, '0')}/${_customDateRange!.start.month.toString().padLeft(2, '0')}/${_customDateRange!.start.year} '
                        'até ${_customDateRange!.end.day.toString().padLeft(2, '0')}/${_customDateRange!.end.month.toString().padLeft(2, '0')}/${_customDateRange!.end.year}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                    ),
                  const SizedBox(height: 16),
                  // Seleção de Curso
                  DropdownButtonFormField<CourseOption>(
                    decoration: const InputDecoration(
                      labelText: 'Curso',
                      prefixIcon: Icon(Icons.school),
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedCourse,
                    isExpanded: true,
                    items: _cursos.map((CourseOption curso) {
                      return DropdownMenuItem<CourseOption>(
                        value: curso,
                        child: Text(curso.nome),
                      );
                    }).toList(),
                    onChanged: (CourseOption? newValue) {
                      setModalState(() {
                        _selectedCourse = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 32),
                  // Botões
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _selectedDateFilter = 'Todas as datas';
                              _customDateRange = null;
                              _selectedCourse = null;
                            });
                            _pagingController.refresh();
                            Navigator.pop(context);
                          },
                          child: const Text('Limpar'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {}); // Atualiza UI na principal
                            _pagingController.refresh();
                            Navigator.pop(context);
                          },
                          child: const Text('Aplicar'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        );
      },
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
