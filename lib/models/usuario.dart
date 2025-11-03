class Usuario {
  final String id;
  final String nome;
  final String sobrenome;
  final String email;
  final String login;
  final String curso;
  final String role;
  final bool active;

  Usuario({
    required this.id,
    required this.nome,
    required this.sobrenome,
    required this.email,
    required this.login,
    required this.curso,
    required this.role,
    this.active = true,
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
      print('[Usuario] Campo active não encontrado no JSON. Chaves disponíveis: ${json.keys.toList()}');
      // Se não vier o campo, assume que está ativo por padrão
      return true;
    }
    
    print('[Usuario] Campo active encontrado: $activeValue (tipo: ${activeValue.runtimeType})');
    
    if (activeValue is bool) {
      return activeValue;
    }
    
    // Se for string, verifica se é 'false' ou '0'
    final activeStr = activeValue.toString().toLowerCase();
    final result = activeStr != 'false' && activeStr != '0';
    print('[Usuario] active parseado como: $result');
    return result;
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
      'active': active,
    };
  }
}

