import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatar datas

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

  // Função para lidar com a publicação do evento
  Future<void> _publicarEvento() async {
    // Valida o formulário antes de continuar
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() => _isLoading = true);
    
    // --- LÓGICA DE API AQUI ---
    // Você vai criar um mapa com os dados a serem enviados.
    final dadosDoEvento = {
      'titulo': _tituloController.text,
      'setor': _setorSelecionado,
      'detalhes': _detalhesController.text,
      'dataInicio': _dataInicio?.toIso8601String(),
      'dataFim': _dataFim?.toIso8601String(),
      // 'imagem': _imagemSelecionada, // Lógica de upload da imagem
    };
    
    print("Publicando evento: $dadosDoEvento");
    // Simula uma chamada à API.
    await Future.delayed(Duration(seconds: 2));
    
    // Exemplo de como seria a chamada real:
    // final sucesso = await EventosApi.criarEvento(dadosDoEvento);

    // if (sucesso && mounted) {
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Evento publicado com sucesso!"), backgroundColor: Colors.green));
    //   // Limpa o formulário após o sucesso
    //   _formKey.currentState?.reset();
    //   setState(() { ... });
    // } else {
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro ao publicar evento."), backgroundColor: Colors.red));
    // }

    setState(() => _isLoading = false);
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
                decoration: InputDecoration(labelText: 'Título do Evento'),
                validator: (v) => v!.isEmpty ? 'O título é obrigatório' : null,
              ),
              SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: _setorSelecionado,
                decoration: InputDecoration(labelText: 'Selecione o Setor/Curso'),
                items: ['Pastoral', 'Odontologia', 'Enfermagem', 'Ciência da Computação']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) => setState(() => _setorSelecionado = value),
                validator: (v) => v == null ? 'Selecione um setor' : null,
              ),
              SizedBox(height: 16),
              
              TextFormField(
                controller: _detalhesController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Detalhes do Evento',
                  alignLabelWithHint: true,
                ),
                validator: (v) => v!.isEmpty ? 'Os detalhes são obrigatórios' : null,
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