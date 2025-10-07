class ManagedUser {
  const ManagedUser({
    required this.id,
    required this.nome,
    required this.sobrenome,
    required this.email,
    required this.login,
    required this.cursoId,
    required this.cursoNome,
    required this.role,
    required this.active,
  });

  factory ManagedUser.fromApi(Map<String, dynamic> json) {
    final cursoRaw = json['curso'];
    String cursoId = '';
    String cursoNome = '';

    if (json['cursoId'] != null) {
      cursoId = json['cursoId'].toString();
    }
    if (json['cursoNome'] != null) {
      cursoNome = json['cursoNome'].toString();
    }

    if (cursoRaw is Map<String, dynamic>) {
      final rawId = cursoRaw['id'] ?? cursoRaw['cursoId'];
      final rawNome = cursoRaw['nome'] ?? cursoRaw['nomeCurso'] ?? cursoRaw['descricao'];
      if (rawId != null && cursoId.isEmpty) cursoId = rawId.toString();
      if (rawNome != null) cursoNome = rawNome.toString();
    } else if (cursoRaw != null) {
      final asString = cursoRaw.toString();
      if (cursoId.isEmpty) cursoId = asString;
      if (cursoNome.isEmpty) cursoNome = asString;
    }

    return ManagedUser(
      id: (json['id'] ?? '').toString(),
      nome: (json['nome'] ?? '').toString(),
      sobrenome: (json['sobrenome'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      login: (json['login'] ?? '').toString(),
      cursoId: cursoId,
      cursoNome: cursoNome,
      role: (json['role'] ?? '').toString(),
      active: json['active'] == null
          ? true
          : (json['active'] is bool
              ? json['active'] as bool
              : json['active'].toString().toLowerCase() != 'false'),
    );
  }

  ManagedUser copyWith({
    String? nome,
    String? sobrenome,
    String? email,
    String? cursoId,
    String? cursoNome,
    String? role,
    bool? active,
  }) {
    return ManagedUser(
      id: id,
      nome: nome ?? this.nome,
      sobrenome: sobrenome ?? this.sobrenome,
      email: email ?? this.email,
      login: login,
      cursoId: cursoId ?? this.cursoId,
      cursoNome: cursoNome ?? this.cursoNome,
      role: role ?? this.role,
      active: active ?? this.active,
    );
  }

  final String id;
  final String nome;
  final String sobrenome;
  final String email;
  final String login;
  final String cursoId;
  final String cursoNome;
  final String role;
  final bool active;

  String get displayName =>
      [nome, sobrenome].where((chunk) => chunk.trim().isNotEmpty).join(' ');

  String get cursoDisplay =>
      cursoNome.isNotEmpty ? cursoNome : (cursoId.isNotEmpty ? 'ID $cursoId' : '');

  String get initials {
    final chunks = [nome, sobrenome]
        .where((chunk) => chunk.trim().isNotEmpty)
        .map((chunk) => chunk.trim()[0].toUpperCase());
    if (chunks.isEmpty) return 'U';
    return chunks.take(2).join();
  }
}
