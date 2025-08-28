import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatar datas
import 'event_service.dart';
import 'user_service.dart';

// --- TELA DE CADASTRO DE EVENTO REATORADA ---
class EVRegister extends StatefulWidget {
  @override
  _EVRegisterState createState() => _EVRegisterState();
}

class _EVRegisterState extends State<EVRegister> {
  final _formKey = GlobalKey<FormState>();

  // Controllers para os campos do formulário
  final _tituloController = TextEditingController();
  final _detalhesController = TextEditingController();
  
  String? _setorSelecionado;
  String? _categoriaIdSelecionada;
  List<String> _categorias = [];
  List<Map<String, String>> _categoriasDetalhadas = [];
  DateTime? _dataInicio;
  DateTime? _dataFim;
  // TODO: Adicionar lógica para lidar com a imagem e arquivos selecionados
  // File? _imagemSelecionada; 
  
  bool _isLoading = false;

  @override
  void dispose() {
    _tituloController.dispose();
    _detalhesController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _carregarCategorias();
  }

  Future<void> _carregarCategorias() async {
    try {
      final lista = await UserService.listarCategorias();
      final detalhadas = await UserService.listarCategoriasDetalhadas();
      if (mounted) {
        setState(() {
          _categorias = lista;
          _categoriasDetalhadas = detalhadas;
        });
      }
    } catch (e) {
      // feedback simples
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha ao carregar categorias: $e'), backgroundColor: Colors.orange),
        );
      }
    }
  }

  // Função para lidar com a publicação do evento
  Future<void> _publicarEvento() async {
    // Valida o formulário antes de continuar
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() => _isLoading = true);
    
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

      // Chama o serviço para criar o evento
      final resultado = await EventService.criarEvento(
        nomeEvento: _tituloController.text,
        descricao: _detalhesController.text,
        dateInicio: DateFormat('yyyy-MM-dd').format(_dataInicio!),
        dateFim: DateFormat('yyyy-MM-dd').format(_dataFim!),
        categoria: _setorSelecionado ?? '',
        categoriaId: _categoriaIdSelecionada,
      );

      print("Resultado da API: $resultado");

      if (resultado['success'] == true) {
        // Sucesso na criação do evento
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(resultado['message'] ?? "Evento publicado com sucesso!"),
              backgroundColor: Colors.green,
            ),
          );
          
          // Limpa o formulário após o sucesso
          _formKey.currentState?.reset();
          _tituloController.clear();
          _detalhesController.clear();
          setState(() {
            _setorSelecionado = null;
            _dataInicio = null;
            _dataFim = null;
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
        title: Text("Cadastrar Novo Evento"),
        automaticallyImplyLeading: false, // Remove a seta de voltar
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- SELETOR DE IMAGEM ---
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
                items: (_categorias.isEmpty ? ['Sem categorias disponíveis'] : _categorias)
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) => setState(() {
                  _setorSelecionado = value;
                  // tenta encontrar o id correspondente
                  final match = _categoriasDetalhadas.firstWhere(
                    (c) => c['nome'] == value,
                    orElse: () => {'id': '', 'nome': ''},
                  );
                  _categoriaIdSelecionada = match['id'];
                }),
                validator: (v) {
                  if (_categorias.isEmpty) return 'Nenhuma categoria disponível';
                  return v == null ? 'Selecione uma categoria' : null;
                },
              ),
              if (_categorias.isEmpty) ...[
                SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () async {
                    final controller = TextEditingController();
                    final nome = await showDialog<String>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Criar categoria'),
                        content: TextField(controller: controller, decoration: InputDecoration(labelText: 'Nome da categoria')),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancelar')),
                          ElevatedButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: Text('Criar')),
                        ],
                      ),
                    );
                    if (nome != null && nome.isNotEmpty) {
                      final criado = await UserService.criarCategoria(nome);
                      if (criado != null) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Categoria criada'), backgroundColor: Colors.green));
                        await _carregarCategorias();
                        setState(() {
                          _setorSelecionado = nome;
                          _categoriaIdSelecionada = criado['id'];
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Falha ao criar categoria'), backgroundColor: Colors.red));
                      }
                    }
                  },
                  icon: Icon(Icons.add),
                  label: Text('Criar categoria'),
                ),
              ],
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

              // --- SELETORES DE DATA ---
              _buildDatePicker(),
              SizedBox(height: 16),
              
              // --- BOTÃO DE UPLOAD ---
              OutlinedButton.icon(
                onPressed: () { /* Lógica para upload de arquivos (PDFs, etc.) */ },
                icon: Icon(Icons.upload_file_outlined),
                label: Text('Anexar Arquivos (Opcional)'),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                ),
              ),
              SizedBox(height: 32),
              
              // --- BOTÃO DE PUBLICAR ---
              ElevatedButton(
                onPressed: _isLoading ? null : _publicarEvento,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                    : Text('PUBLICAR EVENTO'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES PARA ORGANIZAR O CÓDIGO ---

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: () { /* TODO: Lógica para abrir a galeria e selecionar imagem */ },
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade400, width: 1),
        ),
        // TODO: Substituir por `_imagemSelecionada != null ? Image.file(_imagemSelecionada!) : ...`
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_outlined, size: 50, color: Colors.grey[600]),
            SizedBox(height: 8),
            Text("Clique para adicionar uma imagem", style: TextStyle(color: Colors.grey[700])),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
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
              child: Text(_dataInicio == null ? 'Selecionar' : DateFormat('dd/MM/yyyy').format(_dataInicio!)),
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
                firstDate: _dataInicio ?? DateTime.now().subtract(Duration(days: 30)),
                lastDate: DateTime.now().add(Duration(days: 365)),
              );
              if (picked != null) setState(() => _dataFim = picked);
            },
            child: InputDecorator(
              decoration: InputDecoration(labelText: 'Data de Fim'),
              child: Text(_dataFim == null ? 'Selecionar' : DateFormat('dd/MM/yyyy').format(_dataFim!)),
            ),
          ),
        ),
      ],
    );
  }
}