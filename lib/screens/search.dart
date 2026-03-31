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

  // Filtro Ativo
  String _activeFilterType = 'PERIOD';

  // Filtros de Data
  String _selectedDateFilter = 'Todas as datas';
  DateTimeRange? _customDateRange;

  CourseOption? _selectedCourse;
  List<CourseOption> _cursos = [];

  Categoria? _selectedCategoria;
  List<Categoria> _categorias = [];

  // Seleção de Eventos para Relatório
  final Set<String> _selectedEventIds = {};
  bool _isGeneratingReport = false;

  // Constantes de período
  static const List<String> _dateFilters = [
    'Todas as datas',
    'Esta semana',
    'Este mês',
    'Último ano'
  ];

  @override
  void initState() {
    super.initState();
    _carregarCursos();
    _carregarCategorias();
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
      if (!mounted) return;
      setState(() {
        _cursos = cursos;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao carregar cursos: $e')),
      );
    }
  }

  Future<void> _carregarCategorias() async {
    try {
      final categorias = await CategoriaApi.fetchCategorias();
      if (!mounted) return;
      setState(() {
        _categorias = categorias;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao carregar categorias: $e')),
      );
    }
  }

  bool _hasActiveFilter() {
    if (_activeFilterType == 'PERIOD' && _selectedDateFilter != 'Todas as datas') return true;
    if (_activeFilterType == 'COURSE' && _selectedCourse != null) return true;
    if (_activeFilterType == 'CATEGORY' && _selectedCategoria != null) return true;
    return false;
  }

  Map<String, dynamic> _buildSearchParams() {
    Map<String, dynamic> params = {
      "startDate": "",
      "endDate": "",
      "categoryId": "",
      "course": "",
      "eventIds": []
    };

    if (_activeFilterType == 'PERIOD') {
      if (_selectedDateFilter != 'Todas as datas') {
          final agora = DateTime.now();
          if (_selectedDateFilter == 'Esta semana') {
            final inicioSemana = agora.subtract(Duration(days: agora.weekday - 1));
            final fimSemana = inicioSemana.add(const Duration(days: 6, hours: 23, minutes: 59));
            params['startDate'] = inicioSemana.subtract(const Duration(days: 1)).toUtc().toIso8601String();
            params['endDate'] = fimSemana.add(const Duration(days: 1)).toUtc().toIso8601String();
          } else if (_selectedDateFilter == 'Este mês') {
            final inicioMes = DateTime(agora.year, agora.month, 1);
            final fimMes = DateTime(agora.year, agora.month + 1, 0, 23, 59, 59);
            params['startDate'] = inicioMes.toUtc().toIso8601String();
            params['endDate'] = fimMes.toUtc().toIso8601String();
          } else if (_selectedDateFilter == 'Último ano') {
            final umAnoAtras = DateTime(agora.year - 1, agora.month, agora.day);
            params['startDate'] = umAnoAtras.toUtc().toIso8601String();
            params['endDate'] = agora.add(const Duration(days: 1)).toUtc().toIso8601String();
          }
      }
    } else if (_activeFilterType == 'COURSE') {
      if (_selectedCourse != null) {
        params['course'] = _selectedCourse!.id;
      }
    } else if (_activeFilterType == 'CATEGORY') {
      if (_selectedCategoria != null) {
        params['categoryId'] = _selectedCategoria!.id;
      }
    }
    return params;
  }

  // Função que busca os dados da API
  /// Busca eventos com paginação e termo de busca, atualizando o PagingController.
  Future<void> _fetchPage(int pageKey, String query) async {
    try {
      final bool hasActiveFilter = _hasActiveFilter();
      final Map<String, dynamic> params = _buildSearchParams();

      final List<Evento> newItems;
      if (hasActiveFilter) {
        newItems = await EventosApi.searchEventos(
          _activeFilterType, 
          params, 
          pageKey, 
          _pageSize, 
          search: query.trim()
        );
      } else {
        newItems = await EventosApi.fetchEventos(
          pageKey, 
          _pageSize, 
          search: query.trim()
        );
      }
      
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
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.filter_list),
                if ((_activeFilterType == 'PERIOD' && _selectedDateFilter != 'Todas as datas') ||
                    (_activeFilterType == 'COURSE' && _selectedCourse != null) ||
                    (_activeFilterType == 'CATEGORY' && _selectedCategoria != null))
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
      floatingActionButton: (_pagingController.itemList?.isNotEmpty ?? false)
          ? FloatingActionButton.extended(
              onPressed: _isGeneratingReport ? null : () async {
                setState(() => _isGeneratingReport = true);
                try {
                  String filterType;
                  Map<String, dynamic> params;

                  if (_selectedEventIds.isNotEmpty) {
                    filterType = 'IDS';
                    params = {
                      "startDate": "",
                      "endDate": "",
                      "categoryId": "",
                      "course": "",
                      "eventIds": _selectedEventIds.toList()
                    };
                  } else {
                    filterType = _activeFilterType;
                    params = _buildSearchParams();
                  }

                  await EventosApi.gerarRelatorio(filterType, params);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Relatório PDF gerado com sucesso!')),
                    );
                    setState(() {
                      _selectedEventIds.clear();
                    });
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao gerar relatório: $e')),
                    );
                  }
                } finally {
                  if (mounted) setState(() => _isGeneratingReport = false);
                }
              },
              icon: _isGeneratingReport
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.picture_as_pdf),
              label: Text(_isGeneratingReport 
                  ? 'Gerando...' 
                  : _selectedEventIds.isNotEmpty 
                      ? 'Baixar Selecionados (${_selectedEventIds.length})' 
                      : 'Baixar Relatório (Todos)'),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () => Future.sync(_pagingController.refresh),
        child: PagedListView<int, Evento>(
          pagingController: _pagingController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          physics: const AlwaysScrollableScrollPhysics(),
          builderDelegate: PagedChildBuilderDelegate<Evento>(
            itemBuilder: (context, evento, index) {
              final isSelected = _selectedEventIds.contains(evento.id);
              return Stack(
                children: [
                  EventoCard(
                    evento: evento,
                    layout: EventoCardLayout.list,
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedEventIds.remove(evento.id);
                        } else {
                          _selectedEventIds.add(evento.id);
                        }
                      });
                    },
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Transform.scale(
                      scale: 1.2,
                      child: Checkbox(
                        value: isSelected,
                        activeColor: Theme.of(context).primaryColor,
                        onChanged: (bool? val) {
                          setState(() {
                            if (val == true) {
                              _selectedEventIds.add(evento.id);
                            } else {
                              _selectedEventIds.remove(evento.id);
                            }
                          });
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
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
                  
                  // ====== FILTRO DE PERÍODO ======
                  RadioListTile<String>(
                    title: const Text('Por Período', style: TextStyle(fontWeight: FontWeight.bold)),
                    value: 'PERIOD',
                    groupValue: _activeFilterType,
                    onChanged: (String? value) {
                      setModalState(() {
                        _activeFilterType = value!;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  if (_activeFilterType == 'PERIOD')
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                            onChanged: (String? newValue) {
                              setModalState(() {
                                _selectedDateFilter = newValue ?? 'Todas as datas';
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                  // ====== FILTRO DE CURSO ======
                  RadioListTile<String>(
                    title: const Text('Por Curso', style: TextStyle(fontWeight: FontWeight.bold)),
                    value: 'COURSE',
                    groupValue: _activeFilterType,
                    onChanged: (String? value) {
                      setModalState(() {
                        _activeFilterType = value!;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  if (_activeFilterType == 'COURSE')
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                      child: DropdownButtonFormField<CourseOption>(
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
                    ),

                  // ====== FILTRO DE CATEGORIA ======
                  RadioListTile<String>(
                    title: const Text('Por Categoria', style: TextStyle(fontWeight: FontWeight.bold)),
                    value: 'CATEGORY',
                    groupValue: _activeFilterType,
                    onChanged: (String? value) {
                      setModalState(() {
                        _activeFilterType = value!;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  if (_activeFilterType == 'CATEGORY')
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                      child: DropdownButtonFormField<Categoria>(
                        decoration: const InputDecoration(
                          labelText: 'Categoria',
                          prefixIcon: Icon(Icons.category),
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedCategoria,
                        isExpanded: true,
                        items: _categorias.map((Categoria cat) {
                          return DropdownMenuItem<Categoria>(
                             value: cat,
                             child: Text(cat.nome),
                          );
                        }).toList(),
                        onChanged: (Categoria? newValue) {
                          setModalState(() {
                             _selectedCategoria = newValue;
                          });
                        },
                      ),
                    ),
                  
                  const SizedBox(height: 32),
                  // Botões
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _activeFilterType = 'PERIOD';
                              _selectedDateFilter = 'Todas as datas';
                              _customDateRange = null;
                              _selectedCourse = null;
                              _selectedCategoria = null;
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
