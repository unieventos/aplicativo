import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:flutter_application_1/services/api_service.dart' as api_service;
import 'package:flutter_application_1/models/course_option.dart';
import 'package:flutter_application_1/models/evento.dart';
import 'package:flutter_application_1/services/user_service.dart';
import 'package:flutter_application_1/screens/home.dart' as home_page;
import 'package:flutter_application_1/config/app_theme.dart';
import 'package:flutter_application_1/widgets/branded_header.dart';
import 'package:flutter_application_1/widgets/section_title.dart';
import 'package:flutter_application_1/widgets/app_feedback.dart';

/// Tela de edição de evento (formulário + envio para API).
class EditEvent extends StatefulWidget {
  final Evento evento;
  const EditEvent({super.key, required this.evento});

  @override
  _EditEventState createState() => _EditEventState();
}

class _EditEventState extends State<EditEvent> {
  final _formKey = GlobalKey<FormState>();

  final _tituloController = TextEditingController();

  String? _cursoSelecionadoId;
  List<CourseOption> _cursos = [];
  String? _categoriaSelecionadaId;
  List<api_service.Categoria> _categorias = [];
  DateTime? _dataInicio;
  DateTime? _dataFim;
  final ImagePicker _imagePicker = ImagePicker();
  List<XFile> _imagensSelecionadas = [];
  List<Uint8List> _imagensBytes = []; // Para armazenar bytes da imagem no Web
  final TextEditingController _descricaoController = TextEditingController();
  bool _isLoading = false;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _tituloController.text = widget.evento.titulo;
    _descricaoController.text = widget.evento.descricao;
    _dataInicio = widget.evento.inicio;
    _dataFim = widget.evento.fim;

    _carregarFotosExistentes();

    _carregarCursos();
    _carregarCategorias();
    _carregarRole();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _carregarFotosExistentes() async {
    if (widget.evento.fotosIds.isNotEmpty) {
      setState(() => _isLoading = true);
      for (String fotoId in widget.evento.fotosIds) {
        final bytes = await api_service.EventosApi.downloadFotoBytes(fotoId);
        if (bytes != null && mounted) {
          setState(() {
            _imagensSelecionadas
                .add(XFile.fromData(bytes, name: 'foto_$fotoId.jpg'));
            _imagensBytes.add(bytes);
          });
        }
      }
      if (mounted) setState(() => _isLoading = false);
    } else if (widget.evento.imagemBytes != null &&
        widget.evento.imagemBytes!.isNotEmpty) {
      final existingImage =
          XFile.fromData(widget.evento.imagemBytes!, name: 'foto_atual.jpg');
      setState(() {
        _imagensSelecionadas.add(existingImage);
        _imagensBytes.add(widget.evento.imagemBytes!);
      });
    }
  }

  Future<void> _carregarCategorias() async {
    try {
      final categorias = await api_service.CategoriaApi.fetchCategorias();
      if (!mounted) return;
      setState(() {
        _categorias = categorias;
        if (_categorias.isNotEmpty) {
          try {
            final cat = _categorias
                .firstWhere((c) => c.nome == widget.evento.categoria);
            _categoriaSelecionadaId = cat.id;
          } catch (_) {
            _categoriaSelecionadaId = _categorias.first.id;
          }
        }
      });
    } catch (e) {
      if (!mounted) return;
      AppFeedback.error(context, 'Falha ao carregar categorias: $e');
    }
  }

  Future<void> _carregarCursos() async {
    try {
      final cursos = await api_service.UsuarioApi.listarCursos();
      if (!mounted) return;
      setState(() {
        _cursos = cursos;
        if (_cursos.isNotEmpty) {
          try {
            final curso =
                _cursos.firstWhere((c) => c.nome == widget.evento.cursoAutor);
            _cursoSelecionadoId = curso.id;
          } catch (_) {
            _cursoSelecionadoId = _cursos.first.id;
          }
        }
      });
    } catch (e) {
      if (!mounted) return;
      AppFeedback.error(context, 'Falha ao carregar cursos: $e');
    }
  }

  Future<void> _carregarRole() async {
    try {
      final storage = FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true));
      final role = await storage.read(key: 'user_role');
      if (!mounted) return;
      setState(() {
        _userRole = role;
      });
    } catch (e) {
      if (!mounted) return;
      AppFeedback.error(context, 'Falha ao carregar perfil: $e');
    }
  }

  Future<void> _selecionarImagem() async {
    try {
      final List<XFile> imagens = await _imagePicker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (imagens.isNotEmpty) {
        final List<XFile> apenasPng = imagens.where((img) {
          return img.name.toLowerCase().endsWith('.png');
        }).toList();

        if (apenasPng.length < imagens.length) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Apenas fotos em formato .png são aceitas.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }

        if (apenasPng.isNotEmpty) {
          if (kIsWeb) {
            final List<Uint8List> bytesList = [];
            for (var img in apenasPng) {
              bytesList.add(await img.readAsBytes());
            }
            setState(() {
              _imagensSelecionadas.addAll(apenasPng);
              _imagensBytes.addAll(bytesList);
            });
          } else {
            setState(() {
              _imagensSelecionadas.addAll(apenasPng);
              _imagensBytes.addAll(List.filled(apenasPng.length, Uint8List(0)));
            });
          }
        }
      }
    } catch (e) {
      if (!mounted) return;
      AppFeedback.error(context, 'Erro ao selecionar imagens: $e');
    }
  }

  void _removerImagem(int index) {
    setState(() {
      if (index >= 0 && index < _imagensSelecionadas.length) {
        _imagensSelecionadas.removeAt(index);
      }
      if (index >= 0 && index < _imagensBytes.length) {
        _imagensBytes.removeAt(index);
      }
    });
  }

  Future<void> _publicarEvento() async {
    if (!_formKey.currentState!.validate()) return;

    if (_cursoSelecionadoId == null || _cursoSelecionadoId!.isEmpty) {
      AppFeedback.error(context, 'Selecione um curso');
      return;
    }

    if (_categoriaSelecionadaId == null || _categoriaSelecionadaId!.isEmpty) {
      AppFeedback.error(context, 'Selecione uma categoria');
      return;
    }

    if (_dataInicio == null) {
      AppFeedback.error(context, 'Selecione a data de início');
      return;
    }

    if (_dataFim == null) {
      AppFeedback.error(context, 'Selecione a data de fim');
      return;
    }

    if (_dataFim!.isBefore(_dataInicio!)) {
      AppFeedback.error(
          context, 'A data de fim deve ser posterior à data de início');
      return;
    }

    // Permite _imagensSelecionadas estar vazio se o usuário não quiser mudar a foto

    setState(() => _isLoading = true);

    try {
      // Busca o nome do curso selecionado
      final cursoSelecionado = _cursos.firstWhere(
        (c) => c.id == _cursoSelecionadoId,
        orElse: () => _cursos.first,
      );

      final categoriaId = _categoriaSelecionadaId!;

      final dadosEvento = {
        'nomeEvento': _tituloController.text.trim(),
        'descricao': _descricaoController.text.trim(),
        'courseId': _cursoSelecionadoId,
        'categorias': [
          categoriaId.trim()
        ], // Enviando como lista para o backend
        'dateInicio': DateFormat('yyyy-MM-dd').format(_dataInicio!),
        'dateFim': DateFormat('yyyy-MM-dd').format(_dataFim!),
      };

      print('[EditEvent] Editando evento com dados: $dadosEvento');
      print('[EditEvent] Categoria ID: $categoriaId');

      final resultado = await api_service.EventosApi.atualizarEvento(
        widget.evento.id,
        dadosEvento,
        _imagensSelecionadas.isNotEmpty ? _imagensSelecionadas : null,
      );

      print('[EditEvent] Resultado: $resultado');

      if (!mounted) return;

      if (resultado['success'] == true) {
        if (mounted) {
          AppFeedback.success(context, 'Evento editado com sucesso!');
          // Tenta fazer pop, se não conseguir (porque está em IndexedStack),
          // redireciona para a home explícita para recarregar o feed
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop(true);
          } else {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const home_page.EventosPage()),
              (route) => false,
            );
          }
        }
      } else {
        if (mounted) {
          final errorMsg = resultado['error'] ??
              resultado['message'] ??
              'Erro ao criar evento (${resultado['statusCode'] ?? 'desconhecido'})';
          print('[EditEvent] Erro ao criar evento: $errorMsg');
          print('[EditEvent] Detalhes: ${resultado['details']}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      AppFeedback.error(context, 'Erro inesperado: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _exibirDialogNovaCategoria() async {
    final nomeController = TextEditingController();
    bool isSaving = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Nova Categoria'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nomeController,
                    decoration: const InputDecoration(
                      labelText: 'Nome da categoria',
                      hintText: 'Ex: Minicurso, Palestra',
                    ),
                    textInputAction: TextInputAction.done,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          final nome = nomeController.text.trim();
                          if (nome.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Informe o nome da categoria')),
                            );
                            return;
                          }

                          setStateDialog(() => isSaving = true);

                          try {
                            final resultado =
                                await UserService.criarCategoria(nome);
                            if (resultado != null) {
                              String? novoId;
                              if (resultado['id'] != null &&
                                  resultado['id']!.isNotEmpty) {
                                novoId = resultado['id'];
                              }

                              // Polling: tenta buscar a nova categoria na API até 5 vezes
                              for (int i = 0; i < 5; i++) {
                                await _carregarCategorias(); // Atualiza a lista via API
                                try {
                                  // Procura se a categoria já aparece na listagem
                                  final cat = _categorias.firstWhere((c) =>
                                      c.nome.toLowerCase() ==
                                      nome.toLowerCase());
                                  novoId = cat.id;
                                  break; // Encontrou, pode sair do loop
                                } catch (_) {
                                  // Ainda não indexou, aguarda um pouco
                                  await Future.delayed(
                                      const Duration(milliseconds: 500));
                                }
                              }

                              if (novoId != null && novoId.isNotEmpty) {
                                setState(() {
                                  // Garante que o novo ID existe na lista para o Dropdown não dar erro
                                  if (!_categorias.any((c) => c.id == novoId)) {
                                    _categorias.add(api_service.Categoria(
                                        id: novoId!, nome: nome));
                                  }
                                  _categoriaSelecionadaId = novoId;
                                });

                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Categoria criada com sucesso!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } else {
                                throw Exception(
                                    'Não foi possível recuperar o ID da nova categoria.');
                              }
                            } else {
                              throw Exception(
                                  'A API retornou um erro ao criar a categoria.');
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Erro ao criar categoria: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } finally {
                            if (context.mounted) {
                              setStateDialog(() => isSaving = false);
                            }
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BrandedScaffold(
      header: BrandedHeader(
        title: 'Editar evento',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.onPrimary,
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionTitle('Informações básicas'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _tituloController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Título do evento',
                          prefixIcon: Icon(Icons.event_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Título é obrigatório';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: _descricaoController,
                        minLines: 3,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          labelText: 'Descrição',
                          alignLabelWithHint: true,
                          prefixIcon: Icon(Icons.description_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Descrição é obrigatória';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      DropdownButtonFormField<String>(
                        value: _cursoSelecionadoId,
                        decoration: const InputDecoration(
                          labelText: 'Curso',
                          prefixIcon: Icon(Icons.school_outlined),
                        ),
                        isExpanded: true,
                        items: _cursos
                            .map(
                              (curso) => DropdownMenuItem(
                                value: curso.id,
                                child: Text(
                                  curso.nome,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        selectedItemBuilder: (context) {
                          return _cursos.map((curso) {
                            return Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _cursos
                                    .firstWhere(
                                      (c) => c.id == _cursoSelecionadoId,
                                      orElse: () => _cursos.first,
                                    )
                                    .nome,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.black87),
                              ),
                            );
                          }).toList();
                        },
                        onChanged: (value) =>
                            setState(() => _cursoSelecionadoId = value),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Selecione um curso';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _categoriaSelecionadaId,
                              decoration: const InputDecoration(
                                labelText: 'Categoria',
                                prefixIcon: Icon(Icons.category_outlined),
                              ),
                              isExpanded: true,
                              items: _categorias
                                  .map(
                                    (cat) => DropdownMenuItem(
                                      value: cat.id,
                                      child: Text(
                                        cat.nome,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) => setState(
                                  () => _categoriaSelecionadaId = value),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Selecione uma categoria';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              tooltip: 'Criar nova categoria',
                              color: Theme.of(context).primaryColor,
                              onPressed: _exibirDialogNovaCategoria,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SectionTitle('Cronograma'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      _DateTile(
                        label: 'Data de início',
                        value: _dataInicio,
                        onTap: _selecionarDataInicio,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _DateTile(
                        label: 'Data de término',
                        value: _dataFim,
                        onTap: _selecionarDataFim,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SectionTitle('Imagem e divulgação'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _selecionarImagem,
                        icon: const Icon(Icons.library_add_outlined),
                        label: const Text('Adicionar imagens'),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (_imagensSelecionadas.isNotEmpty)
                        SizedBox(
                          height: 180,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _imagensSelecionadas.length,
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        right: AppSpacing.sm),
                                    child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(AppRadius.md),
                                      child: _imagensBytes.length > index &&
                                              _imagensBytes[index].isNotEmpty
                                          ? Image.memory(
                                              _imagensBytes[index],
                                              height: 180,
                                              width: 180,
                                              fit: BoxFit.cover,
                                            )
                                          : (!kIsWeb &&
                                                  _imagensSelecionadas[index]
                                                      .path
                                                      .isNotEmpty
                                              ? Image.file(
                                                  File(_imagensSelecionadas[
                                                          index]
                                                      .path),
                                                  height: 180,
                                                  width: 180,
                                                  fit: BoxFit.cover,
                                                )
                                              : Container(
                                                  height: 180,
                                                  width: 180,
                                                  color: AppColors.background,
                                                  child: const Center(
                                                    child: Icon(Icons.image),
                                                  ),
                                                )),
                                    ),
                                  ),
                                  Positioned(
                                    top: AppSpacing.xs,
                                    right: AppSpacing.md,
                                    child: CircleAvatar(
                                      radius: 16,
                                      backgroundColor: Colors.black54,
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        icon: const Icon(Icons.close,
                                            size: 16, color: Colors.white),
                                        onPressed: () =>
                                            _removerImagem(index),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        )
                      else
                        Container(
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(AppRadius.md),
                            color: AppColors.background,
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Center(
                            child: Text(
                              'Nenhuma imagem selecionada',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppColors.textMuted),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _publicarEvento,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Text(_isLoading ? 'Publicando...' : 'Publicar evento'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selecionarDataInicio() async {
    final DateTime? data = await showDatePicker(
      context: context,
      initialDate: _dataInicio ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (data != null) {
      setState(() {
        _dataInicio = DateTime(
          data.year,
          data.month,
          data.day,
        );
        // Se a data final já estiver selecionada e for menor que a nova data inicial, recetamos ela
        if (_dataFim != null && _dataFim!.isBefore(_dataInicio!)) {
          _dataFim = null;
        }
      });
    }
  }

  Future<void> _selecionarDataFim() async {
    final DateTime? data = await showDatePicker(
      context: context,
      initialDate: _dataFim ?? (_dataInicio ?? DateTime.now()),
      firstDate: _dataInicio ?? DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (data != null) {
      setState(() {
        _dataFim = DateTime(
          data.year,
          data.month,
          data.day,
        );
      });
    }
  }
}

class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 18,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: textTheme.labelMedium),
                const SizedBox(height: 4),
                Text(
                  value != null
                      ? DateFormat('dd/MM/yyyy').format(value!)
                      : 'Selecionar',
                  style: textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
