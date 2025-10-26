class Usuario {
  final String id;
  final String nome;
  final String sobrenome;
  final String email;
  final String login;
  final String curso;
  final String role;

  Usuario({
    required this.id,
    required this.nome,
    required this.sobrenome,
    required this.email,
    required this.login,
    required this.curso,
    required this.role,
  });

  // Getters computados para compatibilidade com o código existente
  String get initials {
    if (nome.isNotEmpty && sobrenome.isNotEmpty) {
      return '${nome[0]}${sobrenome[0]}'.toUpperCase();
    } else if (nome.isNotEmpty) {
      return nome[0].toUpperCase();
    }
    return 'U';
  }

  String get displayName => '$nome $sobrenome'.trim();
  String get cursoDisplay => curso;
  int get cursoId => curso.hashCode; // Para compatibilidade com código que espera int

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] ?? '',
      nome: json['nome'] ?? '',
      sobrenome: json['sobrenome'] ?? '',
      email: json['email'] ?? '',
      login: json['login'] ?? '',
      curso: json['curso'] ?? '',
      role: json['role'] ?? 'USER',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'sobrenome': sobrenome,
      'email': email,
      'login': login,
      'curso': curso,
      'role': role,
    };
  }
}

