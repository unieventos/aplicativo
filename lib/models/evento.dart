class Evento {
  final String id;
  final String titulo;
  final String autor;
  final String cursoAutor;
  final String autorAvatarUrl;
  final String imagemUrl;
  final DateTime data;
  final int participantes;

  Evento({
    required this.id,
    required this.titulo,
    required this.autor,
    required this.cursoAutor,
    required this.autorAvatarUrl,
    required this.imagemUrl,
    required this.data,
    required this.participantes,
  });

  factory Evento.fromJson(Map<String, dynamic> json) {
    // Tenta mapear diferentes possíveis nomes de campos vindos da API
    final dynamic dataRaw = json['data'] ?? json['dataInicio'] ?? json['dateInicio'];
    return Evento(
      id: json['id'] ?? '',
      titulo: json['titulo'] ?? 'Título não informado',
      autor: json['autor'] ?? 'Autor desconhecido',
      cursoAutor: json['cursoAutor'] ?? 'Curso não informado',
      autorAvatarUrl: json['autorAvatarUrl'] ?? '',
      imagemUrl: json['imagemUrl'] ?? '',
      data: dataRaw is String ? (DateTime.tryParse(dataRaw) ?? DateTime.now()) : DateTime.now(),
      participantes: json['participantes'] ?? 0,
    );
  }
}
