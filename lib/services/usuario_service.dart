import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../api/models/usuario_dto_v2.dart';
import '../network/safe_http.dart';

class UsuarioService {
  final SafeHttp _http;
  static const String _baseUrl = 'https://api.unisagrado.edu.br/api'; // Update with your actual base URL

  UsuarioService(this._http);

  // Fetch user profile
  Future<UsuarioDTOV2> getProfile() async {
    final response = await _http.get('$_baseUrl/usuario/perfil');
    
    if (response.statusCode == 200) {
      return UsuarioDTOV2.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load profile: ${response.statusCode}');
    }
  }

  // Update user profile
  Future<UsuarioDTOV2> updateProfile(UsuarioDTOV2 usuario) async {
    final response = await _http.put(
      '$_baseUrl/usuario/perfil',
      body: json.encode(usuario.toJson()),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return UsuarioDTOV2.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update profile: ${response.statusCode}');
    }
  }

  // Upload profile photo
  Future<void> uploadProfilePhoto(File photo) async {
    var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/usuario/foto'));
    
    // Add the photo file to the request
    var photoStream = http.ByteStream(photo.openRead());
    var length = await photo.length();
    var multipartFile = http.MultipartFile(
      'foto', // form field name as expected by the API
      photoStream,
      length,
      filename: photo.path.split('/').last
    );
    
    request.files.add(multipartFile);
    
    // Add any required headers from SafeHttp
    request.headers.addAll(await _http.getHeaders());
    
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    
    if (response.statusCode != 200) {
      throw Exception('Failed to upload photo: ${response.statusCode}');
    }
  }
}