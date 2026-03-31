class Curso {
  final int id;
  final String nome;

  Curso({required this.id, required this.nome});

  factory Curso.fromJson(Map<String, dynamic> json) {
    return Curso(
      id: json['id'] ?? 0,
      // Suporta propriedades diferentes dependendo de como o backend mapeia o curso
      nome: json['nome'] ?? '',
    );
  }
}
