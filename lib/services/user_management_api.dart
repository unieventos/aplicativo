import 'package:flutter_application_1/models/course_option.dart';
import 'package:flutter_application_1/models/managed_user.dart';
import 'package:flutter_application_1/user_service.dart';

class UsuarioApi {
  static Future<List<ManagedUser>> fetchUsuarios(
      int page, int pageSize, String search) async {
    return UserService.listarUsuarios(
      page: page,
      size: pageSize,
      search: search,
    );
  }

  static Future<String?> criarUsuario({
    required String login,
    required String curso,
    required String nome,
    required String sobrenome,
    required String senha,
    String? email,
    String? role,
  }) {
    return UserService.criarUsuario(
      login: login,
      curso: curso,
      nome: nome,
      sobrenome: sobrenome,
      senha: senha,
      email: email,
      role: role,
    );
  }

  static Future<bool> atualizarUsuario(
      String userId, Map<String, dynamic> payload) {
    return UserService.atualizarUsuario(userId, payload);
  }

  static Future<Map<String, dynamic>> deletarUsuario(String userId) {
    return UserService.deletarUsuario(userId);
  }

  static Future<List<CourseOption>> listarCursos() {
    return UserService.listarCursos();
  }

  static Future<CourseOption?> criarCurso(String nome) {
    return UserService.criarCurso(nome);
  }

  static Future<bool> atualizarCurso(String id, String nome) {
    return UserService.atualizarCurso(id, nome);
  }

  static Future<bool> deletarCurso(String id) {
    return UserService.deletarCurso(id);
  }
}
