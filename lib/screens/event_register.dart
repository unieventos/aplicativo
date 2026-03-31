import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:flutter_application_1/api_service.dart' as api_service;
import 'package:flutter_application_1/models/course_option.dart';
import 'package:flutter_application_1/user_service.dart';
import 'package:flutter_application_1/home.dart' as home_page;

/// Tela de cadastro de evento (formulário + envio para API).
class EVRegister extends StatefulWidget {
  const EVRegister({super.key});

  @override
  _EVRegisterState createState() => _EVRegisterState();
}

class _EVRegisterState extends State<EVRegister> {
  final _formKey = GlobalKey<FormState>();

  final _tituloController = TextEditingController();

  String? _cursoSelecionadoId;
  List<CourseOption> _cursos = [];
  String? _categoriaSelecionadaId;
  List<api_service.Categoria> _categorias = [];
  DateTime? _dataInicio;
  DateTime? _dataFim;
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _imagemSelecionada;
  Uint8List? _imagemBytes; // Para armazenar bytes da imagem no Web
  final TextEditingController _descricaoController = TextEditingController();
  bool _isLoading = false;
  String? _userRole;

  @override
  void initState() {
    super.initState();
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

  Future<void> _carregarCategorias() async {
    try {
      final categorias = await api_service.CategoriaApi.fetchCategorias();
      if (!mounted) return;
      setState(() {
        _categorias = categorias;
        if (_categorias.isNotEmpty) {
          // Mantém a categoria selecionada se já existir e continuar válida, caso contrário pega a primeira
          if (_categoriaSelecionadaId == null || !_categorias.any((c) => c.id == _categoriaSelecionadaId)) {
            _categoriaSelecionadaId = _categorias.first.id;
          }
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Falha ao carregar categorias: $e')));
    }
  }

  Future<void> _carregarCursos() async {
    try {
      final cursos = await api_service.UsuarioApi.listarCursos();
      if (!mounted) return;
      setState(() {
        _cursos = cursos;
        if (_cursos.isNotEmpty) {
          _cursoSelecionadoId = _cursos.first.id;
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Falha ao carregar cursos: $e')));
    }
  }

  Future<void> _carregarRole() async {
    try {
      final storage = FlutterSecureStorage();
      final role = await storage.read(key: 'user_role');
      if (!mounted) return;
      setState(() {
        _userRole = role;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Falha ao carregar perfil: $e')));
    }
  }

  Future<void> _selecionarImagem() async {
    try {
      final XFile? imagem = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (imagem != null) {
        // No Web, precisamos ler os bytes para exibir a imagem
        if (kIsWeb) {
          final bytes = await imagem.readAsBytes();
          setState(() {
            _imagemSelecionada = imagem;
            _imagemBytes = bytes;
          });
        } else {
          setState(() {
            _imagemSelecionada = imagem;
            _imagemBytes = null; // Não necessário em outras plataformas
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao selecionar imagem: $e')));
    }
  }

  Future<void> _publicarEvento() async {
    if (!_formKey.currentState!.validate()) return;

    if (_cursoSelecionadoId == null || _cursoSelecionadoId!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecione um curso')));
      return;
    }

    if (_categoriaSelecionadaId == null || _categoriaSelecionadaId!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecione uma categoria')));
      return;
    }

    if (_dataInicio == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione a data de início')),
      );
      return;
    }

    if (_dataFim == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecione a data de fim')));
      return;
    }

    if (_dataFim!.isBefore(_dataInicio!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A data de fim deve ser posterior à data de início'),
        ),
      );
      return;
    }

    if (_imagemSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione uma imagem para o evento'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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

      print('[EVRegister] Criando evento com dados: $dadosEvento');
      print('[EVRegister] Categoria ID: $categoriaId');

      final resultado = await api_service.EventosApi.criarEvento(
        dadosEvento,
        _imagemSelecionada,
      );

      print('[EVRegister] Resultado: $resultado');

      if (!mounted) return;

      if (resultado['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Evento criado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
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
          print('[EVRegister] Erro ao criar evento: $errorMsg');
          print('[EVRegister] Detalhes: ${resultado['details']}');
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text('Erro inesperado: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
                              const SnackBar(content: Text('Informe o nome da categoria')),
                            );
                            return;
                          }

                          setStateDialog(() => isSaving = true);

                          try {
                            final resultado = await UserService.criarCategoria(nome);
                            if (resultado != null) {
                              String? novoId;
                              if (resultado['id'] != null && resultado['id']!.isNotEmpty) {
                                novoId = resultado['id'];
                              }

                              // Polling: tenta buscar a nova categoria na API até 5 vezes
                              for (int i = 0; i < 5; i++) {
                                await _carregarCategorias(); // Atualiza a lista via API
                                try {
                                  // Procura se a categoria já aparece na listagem
                                  final cat = _categorias.firstWhere(
                                      (c) => c.nome.toLowerCase() == nome.toLowerCase());
                                  novoId = cat.id;
                                  break; // Encontrou, pode sair do loop
                                } catch (_) {
                                  // Ainda não indexou, aguarda um pouco
                                  await Future.delayed(const Duration(milliseconds: 500));
                                }
                              }

                              if (novoId != null && novoId.isNotEmpty) {
                                setState(() {
                                  // Garante que o novo ID existe na lista para o Dropdown não dar erro
                                  if (!_categorias.any((c) => c.id == novoId)) {
                                    _categorias.add(api_service.Categoria(id: novoId!, nome: nome));
                                  }
                                  _categoriaSelecionadaId = novoId;
                                });

                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Categoria criada com sucesso!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } else {
                                throw Exception('Não foi possível recuperar o ID da nova categoria.');
                              }
                            } else {
                              throw Exception('A API retornou um erro ao criar a categoria.');
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
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastrar evento'), centerTitle: false),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SectionTitle('Informações básicas'),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
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
                        const SizedBox(height: 16),
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
                        const SizedBox(height: 16),
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
                        const SizedBox(height: 16),
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
                                onChanged: (value) =>
                                    setState(() => _categoriaSelecionadaId = value),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Selecione uma categoria';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
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
                const SizedBox(height: 24),
                _SectionTitle('Cronograma'),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        _DateTile(
                          label: 'Data de início',
                          value: _dataInicio,
                          onTap: _selecionarDataInicio,
                        ),
                        const SizedBox(height: 12),
                        _DateTile(
                          label: 'Data de término',
                          value: _dataFim,
                          onTap: _selecionarDataFim,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _SectionTitle('Imagem e divulgação'),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _selecionarImagem,
                          icon: const Icon(Icons.image_outlined),
                          label: Text(
                            _imagemSelecionada == null
                                ? 'Selecionar imagem'
                                : 'Trocar imagem',
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_imagemSelecionada != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: kIsWeb && _imagemBytes != null
                                ? Image.memory(
                                    _imagemBytes!,
                                    height: 180,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    File(_imagemSelecionada!.path),
                                    height: 180,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                          )
                        else
                          Container(
                            height: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.grey.shade100,
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: const Center(
                              child: Text('Nenhuma imagem selecionada'),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    );
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined),
            const SizedBox(width: 12),
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
