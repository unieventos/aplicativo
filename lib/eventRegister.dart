import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'event_service.dart';
import 'user_service.dart';
import 'models/course_option.dart';

// --- TELA DE CADASTRO DE EVENTO FINALIZADA ---
class EVRegister extends StatefulWidget {
  @override
  _EVRegisterState createState() => _EVRegisterState();
}

class _EVRegisterState extends State<EVRegister> {
  final _formKey = GlobalKey<FormState>();

  final _tituloController = TextEditingController();

  String? _cursoSelecionadoId;
  List<CourseOption> _cursos = [];
  DateTime? _dataInicio;
  DateTime? _dataFim;
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _imagemSelecionada;
  final TextEditingController _descricaoController = TextEditingController();
  bool _isLoading = false;
  String? _userRole;

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

<<<<<<< HEAD
  @override
  void initState() {
    super.initState();
    _carregarCursos();
    _carregarRole();
  }

  Future<void> _carregarCursos() async {
    try {
      final detalhadas = await UserService.listarCursos();
      if (mounted) {
        setState(() {
          _cursos = detalhadas;
          if (_cursos.isEmpty) {
            _cursoSelecionadoId = null;
          } else if (_cursoSelecionadoId != null &&
              !_cursos.any((c) => c.id == _cursoSelecionadoId)) {
            _cursoSelecionadoId = null;
          }
        });
      }
    } catch (e) {
      // feedback simples
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Falha ao carregar cursos: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  String? _buscarCursoIdPorNome(String? nome) {
    if (nome == null || nome.isEmpty) return null;
    final alvo = nome.trim().toLowerCase();
    for (final curso in _cursos) {
      if (curso.nome.trim().toLowerCase() == alvo) {
        return curso.id;
      }
    }
    return null;
  }

  Future<void> _carregarRole() async {
    final storage = FlutterSecureStorage();
    final role = await storage.read(key: 'role');
    setState(() {
      _userRole = role;
    });
  }

  // Função para lidar com a publicação do evento
=======
  // Função para lidar com a publicação do evento, agora conectada à API.
>>>>>>> origin/main
  Future<void> _publicarEvento() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_cursoSelecionadoId == null || _cursoSelecionadoId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Selecione um curso"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final descricaoPlain = _descricaoController.text.trim();

    setState(() {
      _isLoading = true;
    });

    try {
      // Valida se as datas foram selecionadas
      if (_dataInicio == null || _dataFim == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Selecione as datas de início e fim do evento"),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() => _isLoading = false);
        return;
      }

      if (_dataFim!.isBefore(_dataInicio!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("A data de fim deve ser posterior à data de início"),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() => _isLoading = false);
        return;
      }

      FocusScope.of(context).unfocus();

      final cursoSelecionado = _cursos.firstWhere(
          (c) => c.id == _cursoSelecionadoId,
          orElse: () => CourseOption(id: _cursoSelecionadoId!, nome: ''));

      // Chama o serviço para criar o evento
      final resultado = await EventService.criarEvento(
        nomeEvento: _tituloController.text.trim(),
        descricao: descricaoPlain,
        dateInicio: _dataInicio!,
        dateFim: _dataFim!,
        categoriaId: _cursoSelecionadoId,
        categoriaNome:
            cursoSelecionado.nome.isNotEmpty ? cursoSelecionado.nome : null,
      );

      print("Resultado da API: $resultado");

      if (resultado['success'] == true) {
        String feedback = (resultado['message'] as String?) ??
            "Evento publicado com sucesso!";
        String? uploadFeedback;
        bool uploadOk = true;

        if (_imagemSelecionada != null) {
          final eventId = resultado['eventId'] as String?;
          if (eventId != null && eventId.isNotEmpty) {
            final upload = await EventService.enviarArquivoEvento(
              arquivo: File(_imagemSelecionada!.path),
              eventoId: eventId,
            );
            uploadOk = upload['success'] == true;
            uploadFeedback = (upload['message'] as String?) ??
                (uploadOk
                    ? 'Imagem anexada com sucesso.'
                    : 'Não foi possível anexar a imagem.');
          } else {
            uploadOk = false;
            uploadFeedback =
                'Evento criado, mas não recebemos o identificador para anexar a imagem.';
          }
        }

        if (mounted) {
          final messages = <String>[feedback];
          if (uploadFeedback != null && uploadFeedback.isNotEmpty) {
            messages.add(uploadFeedback);
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(messages.join('\n')),
              backgroundColor: uploadOk ? Colors.green : Colors.orange,
            ),
          );

          _formKey.currentState?.reset();
          _tituloController.clear();
          _limparDescricao();
          setState(() {
            _cursoSelecionadoId = null;
            _dataInicio = null;
            _dataFim = null;
            _imagemSelecionada = null;
          });
        }
      } else {
        // Erro na API
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(resultado['message'] ?? "Erro ao publicar evento"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print("Erro na requisição: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro de conexão: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
<<<<<<< HEAD
        title: const Text('Cadastrar Novo Evento'),
        automaticallyImplyLeading: false,
        centerTitle: false,
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.deferToChild,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildImagePicker(),
                const SizedBox(height: 12),
                Text(
                  'Toque no quadro acima para selecionar uma imagem (opcional).',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _tituloController,
                  decoration:
                      const InputDecoration(labelText: 'Nome do Evento'),
                  validator: (value) => value == null || value.isEmpty
                      ? 'O nome do evento é obrigatório'
                      : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _cursoSelecionadoId,
                  decoration: const InputDecoration(labelText: 'Curso'),
                  hint: Text(
                    _cursos.isEmpty
                        ? 'Nenhum curso cadastrado'
                        : 'Selecione o curso',
                  ),
                  items: _cursos
                      .map((curso) => DropdownMenuItem<String>(
                            value: curso.id,
                            child: Text(curso.nome),
                          ))
                      .toList(),
                  onChanged: _cursos.isEmpty
                      ? null
                      : (value) => setState(() {
                            _cursoSelecionadoId = value;
                          }),
                  validator: (_) {
                    if (_cursos.isEmpty) return 'Nenhum curso disponível';
                    return _cursoSelecionadoId == null
                        ? 'Selecione um curso'
                        : null;
                  },
=======
        title: Text("Cadastrar Novo Evento"),
        automaticallyImplyLeading: false,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImagePicker(),
              SizedBox(height: 24),
              
              // --- CAMPOS DO FORMULÁRIO ---
              TextFormField(
                controller: _tituloController,
                decoration: InputDecoration(labelText: 'Nome do Evento'),
                validator: (v) => v!.isEmpty ? 'O nome do evento é obrigatório' : null,
              ),
              SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: _setorSelecionado,
                decoration: InputDecoration(labelText: 'Categoria'),
                items: ['Pastoral', 'Odontologia', 'Enfermagem', 'Ciência da Computação']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) => setState(() => _setorSelecionado = value),
                validator: (v) => v == null ? 'Selecione uma categoria' : null,
              ),
              SizedBox(height: 16),
              
              TextFormField(
                controller: _detalhesController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Descrição',
                  alignLabelWithHint: true,
                ),
                validator: (v) => v!.isEmpty ? 'A descrição é obrigatória' : null,
              ),
              SizedBox(height: 24),

              _buildDatePicker(),
              SizedBox(height: 16),
              
              OutlinedButton.icon(
                onPressed: () { /* Lógica para upload de arquivos (PDFs, etc.) */ },
                icon: Icon(Icons.upload_file_outlined),
                label: Text('Anexar Arquivos (Opcional)'),
                style: OutlinedButton.styleFrom(minimumSize: Size(double.infinity, 48)),
              ),
              SizedBox(height: 32),
              
              ElevatedButton(
                onPressed: _isLoading ? null : _publicarEvento,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                  padding: EdgeInsets.symmetric(vertical: 16),
>>>>>>> origin/main
                ),
                if (_userRole?.toLowerCase() == 'admin') ...[
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _onCadastrarCurso,
                    icon: const Icon(Icons.add),
                    label: const Text('Cadastrar curso'),
                  ),
                ],
                const SizedBox(height: 16),
                _buildDescricaoField(),
                const SizedBox(height: 16),
                _buildDatePicker(),
                const SizedBox(height: 16),
                if (_imagemSelecionada != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Imagem selecionada: ${_imagemSelecionada!.name}',
                    style: TextStyle(color: Colors.grey[700], fontSize: 12),
                  ),
                ],
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _publicarEvento,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text('PUBLICAR EVENTO'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

<<<<<<< HEAD
  Future<void> _onCadastrarCurso() async {
    final controller = TextEditingController();
    final nome = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cadastrar curso'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Nome do curso'),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (!mounted) return;
    final nomeNormalizado = nome?.trim();
    if (nomeNormalizado == null || nomeNormalizado.isEmpty) {
      return;
    }

    try {
      final criado = await UserService.criarCategoria(nomeNormalizado);
      if (criado != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Curso cadastrado com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
        await _carregarCursos();
        setState(() {
          _cursoSelecionadoId = criado['id']?.isNotEmpty == true
              ? criado['id']
              : _buscarCursoIdPorNome(criado['nome']);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Falha ao cadastrar curso'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao cadastrar curso: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildDescricaoField() {
    return TextFormField(
      controller: _descricaoController,
      minLines: 6,
      maxLines: 12,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      decoration: const InputDecoration(
        labelText: 'Descrição',
        alignLabelWithHint: true,
        hintText: 'Descreva o evento com os detalhes necessários...',
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'A descrição é obrigatória';
        }
        return null;
      },
    );
  }

=======
>>>>>>> origin/main
  Widget _buildImagePicker() {
    final selected = _imagemSelecionada;
    return GestureDetector(
      onTap: _isLoading ? null : _selecionarImagem,
      child: Container(
        height: 200,
        width: double.infinity,
<<<<<<< HEAD
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade400, width: 1),
        ),
        child: selected == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_outlined,
                      size: 50, color: Colors.grey[600]),
                  SizedBox(height: 8),
                  Text(
                    "Toque para adicionar uma imagem",
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              )
            : Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(selected.path),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(Icons.close, color: Colors.white, size: 18),
                        onPressed: _isLoading
                            ? null
                            : () {
                                setState(() => _imagemSelecionada = null);
                              },
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _limparDescricao() {
    if (_descricaoController.text.isNotEmpty) {
      _descricaoController.clear();
    }
  }

  Future<void> _selecionarImagem() async {
    if (_isLoading) return;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
=======
        decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade400)),
>>>>>>> origin/main
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_library_outlined),
              title: Text('Escolher da galeria'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: Icon(Icons.photo_camera_outlined),
              title: Text('Usar câmera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
      );
      if (!mounted) return;
      if (picked != null) {
        setState(() => _imagemSelecionada = picked);
      }
    } on PlatformException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Permissão negada: ${e.message ?? ''}'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao selecionar imagem: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildDatePicker() {
<<<<<<< HEAD
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now().subtract(Duration(days: 30)),
                lastDate: DateTime.now().add(Duration(days: 365)),
              );
              if (picked != null) setState(() => _dataInicio = picked);
            },
            child: InputDecorator(
              decoration: InputDecoration(labelText: 'Data de Início'),
              child: Text(_dataInicio == null
                  ? 'Selecionar'
                  : DateFormat('dd/MM/yyyy').format(_dataInicio!)),
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: InkWell(
            onTap: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _dataInicio ?? DateTime.now(),
                firstDate:
                    _dataInicio ?? DateTime.now().subtract(Duration(days: 30)),
                lastDate: DateTime.now().add(Duration(days: 365)),
              );
              if (picked != null) setState(() => _dataFim = picked);
            },
            child: InputDecorator(
              decoration: InputDecoration(labelText: 'Data de Fim'),
              child: Text(_dataFim == null
                  ? 'Selecionar'
                  : DateFormat('dd/MM/yyyy').format(_dataFim!)),
            ),
          ),
        ),
      ],
    );
  }
}
=======
    return FormField<DateTime>(
      validator: (value) {
        if (_dataInicio == null) {
          return 'A data de início é obrigatória.';
        }
        return null;
      },
      builder: (FormFieldState<DateTime> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now().subtract(Duration(days: 30)), lastDate: DateTime.now().add(Duration(days: 365)));
                      if (picked != null) setState(() => _dataInicio = picked);
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(labelText: 'Data de Início', errorText: state.errorText),
                      child: Text(_dataInicio == null ? 'Selecionar' : DateFormat('dd/MM/yyyy').format(_dataInicio!)),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      DateTime? picked = await showDatePicker(context: context, initialDate: _dataInicio ?? DateTime.now(), firstDate: _dataInicio ?? DateTime.now().subtract(Duration(days: 30)), lastDate: DateTime.now().add(Duration(days: 365)));
                      if (picked != null) setState(() => _dataFim = picked);
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(labelText: 'Data de Fim (Opcional)'),
                      child: Text(_dataFim == null ? 'Selecionar' : DateFormat('dd/MM/yyyy').format(_dataFim!)),
                    ),
                  ),
                ),
              ],
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                child: Text(state.errorText!, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
              ),
          ],
        );
      },
    );
  }
}

// API de eventos centralizada em lib/api_service.dart
>>>>>>> origin/main
