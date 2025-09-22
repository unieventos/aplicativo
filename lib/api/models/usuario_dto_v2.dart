class UsuarioDTOV2 {
  final String id;
  final String nome;
  final String sobrenome;
  final String? email; // Optional
  final String cursoId;
  final String? role; // Optional

  UsuarioDTOV2({
    required this.id,
    required this.nome,
    required this.sobrenome,
    this.email,
    required this.cursoId,
    this.role,
  });

  factory UsuarioDTOV2.fromJson(Map<String, dynamic> json) {
    return UsuarioDTOV2(
      id: json['id'],
      nome: json['nome'],
      sobrenome: json['sobrenome'],
      email: json['email'],
      cursoId: json['cursoId'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'sobrenome': sobrenome,
      'email': email,
      'cursoId': cursoId,
      'role': role,
    };
  }

  // Convenience method to create a copy with modified fields
  UsuarioDTOV2 copyWith({
    String? id,
    String? nome,
    String? sobrenome,
    String? email,
    String? cursoId,
    String? role,
  }) {
    return UsuarioDTOV2(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      sobrenome: sobrenome ?? this.sobrenome,
      email: email ?? this.email,
      cursoId: cursoId ?? this.cursoId,
      role: role ?? this.role,
    );
  }
}