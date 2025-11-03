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
      active: _parseActive(json),
    );
  }

  static bool _parseActive(Map<String, dynamic> json) {
    // Tenta diferentes possíveis nomes do campo
    final activeValue = json['active'] ?? 
                        json['is_active'] ?? 
                        json['isActive'] ?? 
                        json['ativo'];
    
    // Debug: log para verificar o que está vindo
    if (activeValue == null) {
      print('[ManagedUser] Campo active não encontrado no JSON. Chaves disponíveis: ${json.keys.toList()}');
      // Se não vier o campo, assume que está ativo por padrão
      // Mas vamos verificar se há algum campo que indique inativo
      return true;
    }
    
    print('[ManagedUser] Campo active encontrado: $activeValue (tipo: ${activeValue.runtimeType})');
    
    if (activeValue is bool) {
      return activeValue;
    }
    
    // Se for string, verifica se é 'false' ou '0'
    final activeStr = activeValue.toString().toLowerCase();
    final result = activeStr != 'false' && activeStr != '0';
    print('[ManagedUser] active parseado como: $result');
    return result;
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
