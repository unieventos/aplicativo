import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:flutter_application_1/api_service.dart' as api_service;

// --- TELA DE CADASTRO DE EVENTO FINALIZADA ---
class EVRegister extends StatefulWidget {
  const EVRegister({super.key});

  @override
  _EVRegisterState createState() => _EVRegisterState();
}

class _EVRegisterState extends State<EVRegister> {
  final _formKey = GlobalKey<FormState>();

  final _tituloController = TextEditingController();

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
          _categoriaSelecionadaId = _categorias.first.id;
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Falha ao carregar categorias: $e')));
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

    setState(() => _isLoading = true);

    try {
      final dadosEvento = {
        'nomeEvento': _tituloController.text.trim(),
        'descricao': _descricaoController.text.trim(),
        'categoria': _categoriaSelecionadaId!,
        'dateInicio': DateFormat('yyyy-MM-dd').format(_dataInicio!),
        'dateFim': DateFormat('yyyy-MM-dd').format(_dataFim!),
      };

      final resultado = await api_service.EventosApi.criarEvento(
        dadosEvento,
        _imagemSelecionada,
      );

      if (!mounted) return;

      if (resultado['success'] == true) {
        final eventoId = resultado['eventId'];
        
        // Se há imagem e evento foi criado, fazer upload
        if (_imagemSelecionada != null && eventoId != null) {
          try {
            // No Web, usa bytes; em outras plataformas, usa File
            final uploadResult = kIsWeb && _imagemBytes != null
                ? await api_service.EventosApi.enviarImagemEvento(
                    _imagemBytes!,
                    eventoId,
                    nomeArquivo: _imagemSelecionada!.name,
                    mimeTypeString: _imagemSelecionada!.mimeType,
                  )
                : await api_service.EventosApi.enviarImagemEvento(
                    File(_imagemSelecionada!.path),
                    eventoId,
                  );
            
            if (uploadResult['success'] != true) {
              // Avisa mas não falha, pois o evento já foi criado
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(uploadResult['message'] ?? 
                                 uploadResult['error'] ?? 
                                 'Evento criado, mas houve erro ao enviar imagem'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            }
          } catch (e) {
            // Log do erro mas não bloqueia
            print('Erro ao enviar imagem: $e');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Evento criado, mas houve erro ao enviar imagem'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          }
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Evento criado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(resultado['error'] ?? 'Erro ao criar evento'),
              backgroundColor: Colors.red,
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
                          value: _categoriaSelecionadaId,
                          decoration: const InputDecoration(
                            labelText: 'Categoria',
                            prefixIcon: Icon(Icons.category_outlined),
                          ),
                          isExpanded: true,
                          items: _categorias
                              .map(
                                (categoria) => DropdownMenuItem(
                                  value: categoria.id,
                                  child: Text(
                                    categoria.nome,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          selectedItemBuilder: (context) {
                            return _categorias.map((categoria) {
                              return Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  _categorias.firstWhere(
                                    (c) => c.id == _categoriaSelecionadaId,
                                    orElse: () => _categorias.first,
                                  ).nome,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.black87),
                                ),
                              );
                            }).toList();
                          },
                          onChanged: (value) =>
                              setState(() => _categoriaSelecionadaId = value),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Selecione uma categoria';
                            }
                            return null;
                          },
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
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (data != null) {
        setState(() {
          _dataInicio = DateTime(
            data.year,
            data.month,
            data.day,
          );
        });
    }
  }

  Future<void> _selecionarDataFim() async {
    final DateTime? data = await showDatePicker(
      context: context,
      initialDate: _dataFim ?? (_dataInicio ?? DateTime.now()),
      firstDate: _dataInicio ?? DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
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
