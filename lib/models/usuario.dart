/// Modelo de Usuário conforme retorno do backend.
class Usuario {
  final String id;
  final String nome;
  final String sobrenome;
  final String email;
  final String login;
  final int cursoId;
  final String cursoNome;

  final String role;
  final bool active;

  Usuario({
    required this.id,
    required this.nome,
    required this.sobrenome,
    required this.email,
    required this.login,
    required this.cursoId,
    this.cursoNome = '',
    this.role = '',
    this.active = true,
  });

  String get displayName => nome.isNotEmpty ? '$nome $sobrenome'.trim() : (login.isNotEmpty ? login : 'Usuário');
  String get initials => nome.isNotEmpty ? nome[0].toUpperCase() : (login.isNotEmpty ? login[0].toUpperCase() : 'U');
  String get cursoDisplay => cursoNome.isNotEmpty ? cursoNome : 'Não informado';
  String get curso => cursoNome;

  /// Constrói um Usuário a partir de um JSON de resposta.
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] ?? '',
      nome: json['nome'] ?? '',
      sobrenome: json['sobrenome'] ?? '',
      email: json['email'] ?? '',
      login: json['login'] ?? json['username'] ?? json['user']?['login'] ?? json['usuario']?['login'] ?? '',
      cursoId: json['cursoId'] ?? 0,
      cursoNome: json['cursoNome'] ?? json['curso'] ?? '',
      role: json['role'] ?? '',
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
