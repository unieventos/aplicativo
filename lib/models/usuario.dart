/// Modelo de Usuário conforme retorno do backend.
class Usuario {
  final String id;
  final String nome;
  final String sobrenome;
  final String email;
  final String login;
  final int cursoId;
  final String cursoNome;

  Usuario({
    required this.id,
    required this.nome,
    required this.sobrenome,
    required this.email,
    required this.login,
    required this.cursoId,
    this.cursoNome = '',
  });

  /// Constrói um Usuário a partir de um JSON de resposta.
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] ?? '',
      nome: json['nome'] ?? '',
      sobrenome: json['sobrenome'] ?? '',
      email: json['email'] ?? '',
      login: json['login'] ?? '',
      cursoId: json['cursoId'] ?? 0,
    );
  }
}
