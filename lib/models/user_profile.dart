class UserProfile {
  const UserProfile({
    this.id = '',
    this.nome = '',
    this.sobrenome = '',
    this.email = '',
    this.cursoId = '',
    this.role = 'user',
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id']?.toString() ?? '',
      nome: map['nome']?.toString() ?? '',
      sobrenome: map['sobrenome']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      cursoId: map['cursoId']?.toString() ?? '',
      role: map['role']?.toString() ?? 'user',
    );
  }

  final String id;
  final String nome;
  final String sobrenome;
  final String email;
  final String cursoId;
  final String role;

  String get initials {
    final buffer = StringBuffer();
    if (nome.isNotEmpty) buffer.write(nome.trim()[0].toUpperCase());
    if (sobrenome.isNotEmpty) {
      final trimmed = sobrenome.trim();
      if (trimmed.isNotEmpty) buffer.write(trimmed[0].toUpperCase());
    }
    final value = buffer.toString();
    return value.isNotEmpty ? value : 'U';
  }

  String get fullName {
    return [nome, sobrenome]
        .where((chunk) => chunk.trim().isNotEmpty)
        .join(' ')
        .trim();
  }
}
