class Evento {
  final String id;
  final String titulo;
  final String descricao;
  final String autor;
  final String criador;
  final String cursoAutor;
  final String autorAvatarUrl;
  final String imagemUrl;
  final DateTime data;
  final DateTime inicio;
  final DateTime fim;
  final String categoria;
  final int participantes;

  Evento({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.autor,
    required this.criador,
    required this.cursoAutor,
    required this.autorAvatarUrl,
    required this.imagemUrl,
    required this.data,
    required this.inicio,
    required this.fim,
    required this.categoria,
    required this.participantes,
  });

  // Getters para compatibilidade com código existente
  String get nome => titulo;

  factory Evento.fromJson(Map<String, dynamic> json) {
    // Mapeia os campos da API conforme a documentação
    final dynamic dataRaw = json['data'] ?? json['dataInicio'] ?? json['dateInicio'];
    final dynamic inicioRaw = json['inicio'] ?? json['dataInicio'] ?? json['dateInicio'];
    final dynamic fimRaw = json['fim'] ?? json['dataFim'] ?? json['dateFim'];
    
    // Conta participantes da lista usuariosPermissao
    final usuariosPermissao = json['usuariosPermissao'];
    final int participantesCount = usuariosPermissao is List ? usuariosPermissao.length : 0;
    
    // Extrai categoria se existir (pode vir como objeto ou string)
    String categoriaNome = '';
    final categoriaRaw = json['eventoCategoria'];
    if (categoriaRaw is List && categoriaRaw.isNotEmpty) {
      final primeiraCategoria = categoriaRaw.first;
      if (primeiraCategoria is Map<String, dynamic>) {
        categoriaNome = primeiraCategoria['nomeCategoria'] ?? primeiraCategoria['nome'] ?? '';
      }
    } else if (categoriaRaw is String) {
      categoriaNome = categoriaRaw;
    } else if (categoriaRaw is Map<String, dynamic>) {
      categoriaNome = categoriaRaw['nomeCategoria'] ?? categoriaRaw['nome'] ?? '';
    }
    
    return Evento(
      id: json['id'] ?? '',
      // API retorna 'nomeEvento', não 'titulo' ou 'nome'
      titulo: json['nomeEvento'] ?? json['titulo'] ?? json['nome'] ?? 'Título não informado',
      descricao: json['descricao'] ?? json['description'] ?? '',
      // API retorna 'usuarioCriador'
      autor: json['usuarioCriador'] ?? json['autor'] ?? json['criador'] ?? 'Autor desconhecido',
      criador: json['usuarioCriador'] ?? json['criador'] ?? json['autor'] ?? 'Criador desconhecido',
      cursoAutor: json['cursoAutor'] ?? json['curso'] ?? 'Curso não informado',
      autorAvatarUrl: json['autorAvatarUrl'] ?? json['avatarUrl'] ?? '',
      imagemUrl: json['imagemUrl'] ?? json['imagem'] ?? '',
      data: dataRaw is String ? (DateTime.tryParse(dataRaw) ?? DateTime.now()) : DateTime.now(),
      inicio: inicioRaw is String ? (DateTime.tryParse(inicioRaw) ?? DateTime.now()) : DateTime.now(),
      fim: fimRaw is String ? (DateTime.tryParse(fimRaw) ?? DateTime.now()) : DateTime.now(),
      categoria: categoriaNome.isNotEmpty 
          ? categoriaNome 
          : (json['categoria'] ?? json['category'] ?? ''),
      participantes: participantesCount > 0 
          ? participantesCount 
          : (json['participantes'] ?? json['participants'] ?? 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'autor': autor,
      'criador': criador,
      'cursoAutor': cursoAutor,
      'autorAvatarUrl': autorAvatarUrl,
      'imagemUrl': imagemUrl,
      'data': data.toIso8601String(),
      'inicio': inicio.toIso8601String(),
      'fim': fim.toIso8601String(),
      'categoria': categoria,
      'participantes': participantes,
    };
  }
}
