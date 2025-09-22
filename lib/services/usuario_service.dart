import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../api/models/usuario_dto_v2.dart';
import '../network/safe_http.dart';

class UsuarioService {
  /// Base URL for all user-related API endpoints
  static const String _baseUrl = 'http://172.171.192.14:8081/unieventos';

  UsuarioService();

  /// Fetches the current user's profile data
  Future<UsuarioDTOV2> getProfile() async {
    debugPrint('🔍 Starting getProfile()');
    
    try {
      debugPrint('🔍 Getting headers...');
      final headers = await SafeHttp.getHeaders();
      
      // Use the working endpoint
      final url = Uri.parse('$_baseUrl/usuarios/me');
      debugPrint('🔍 Making request to: $url');
      
      final response = await SafeHttp.get(url, headers: headers);
      debugPrint('✅ Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final responseBody = response.bodyAsString();
        debugPrint('📦 Response body: $responseBody');
        
        try {
          final jsonData = json.decode(responseBody);
          
          // Handle the nested user object in the response
          if (jsonData is Map && jsonData.containsKey('user')) {
            return UsuarioDTOV2.fromJson(jsonData['user']);
          } else {
            // Fallback to direct parsing if the structure is different
            return UsuarioDTOV2.fromJson(jsonData);
          }
        } catch (e) {
          debugPrint('❌ Error parsing response: $e');
          throw Exception('Failed to parse server response');
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        debugPrint('🔒 Authentication error (${response.statusCode})');
        throw Exception('Authentication required. Please log in again.');
      } else if (response.statusCode >= 500) {
        final responseBody = response.bodyAsString();
        debugPrint('⚠️ Server error (${response.statusCode})');
        debugPrint('📦 Response body: $responseBody');
        throw Exception('Server error (${response.statusCode})');
      } else {
        debugPrint('⚠️ Unexpected status code: ${response.statusCode}');
        throw Exception('Failed to load profile: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error in getProfile: $e');
      rethrow;
    }
  }

  /// Updates the current user's profile
  /// Endpoint: PUT /usuarios/{id}
  Future<UsuarioDTOV2> updateProfile(UsuarioDTOV2 usuario) async {
    debugPrint('🔄 Starting updateProfile for user: ${usuario.id}');
    
    try {
      final headers = await SafeHttp.getHeaders();
      headers['Content-Type'] = 'application/json';
      
      // Use the correct endpoint for updating user profile
      final url = Uri.parse('$_baseUrl/usuarios/${usuario.id}');
      
      // Prepare the request body according to the API's expected format
      final requestBody = json.encode({
        'nome': usuario.nome,
        'sobrenome': usuario.sobrenome,
        'email': usuario.email,
        'cursoId': usuario.cursoId,
        'role': usuario.role,
      });
      
      debugPrint('📤 Sending PUT request to: $url');
      debugPrint('📝 Request body: $requestBody');
      
      final response = await SafeHttp.put(
        url,
        body: requestBody,
        headers: headers,
      );

      debugPrint('✅ Update profile response status: ${response.statusCode}');
      final responseBody = response.bodyAsString();
      debugPrint('📦 Response body: $responseBody');

      if (response.statusCode == 200) {
        try {
          final responseData = json.decode(responseBody);
          
          // Handle the nested user object in the response
          if (responseData is Map && responseData.containsKey('user')) {
            return UsuarioDTOV2.fromJson(responseData['user']);
          } else {
            return UsuarioDTOV2.fromJson(responseData);
          }
        } catch (e) {
          debugPrint('❌ Error parsing update profile response: $e');
          // If we can't parse the response but got a 200, return the original user
          // as the update might have been successful
          return usuario;
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        debugPrint('🔒 Authentication error (${response.statusCode})');
        throw Exception('Sessão expirada. Por favor, faça login novamente.');
      } else if (response.statusCode >= 500) {
        debugPrint('⚠️ Server error (${response.statusCode})');
        throw Exception('Erro no servidor. Por favor, tente novamente mais tarde.');
      } else {
        debugPrint('⚠️ Unexpected status code: ${response.statusCode}');
        
        // Try to parse error message from response
        try {
          final errorData = json.decode(responseBody);
          final errorMessage = errorData['message'] ?? 'Falha ao atualizar perfil';
          throw Exception(errorMessage);
        } catch (e) {
          throw Exception('Falha ao atualizar perfil (${response.statusCode})');
        }
      }
    } catch (e) {
      debugPrint('❌ Error in updateProfile: $e');
      rethrow;
    }
  }

  /// Uploads a profile photo
  /// Endpoint: POST /usuarios/{id}/foto
  Future<void> uploadProfilePhoto(File photo, String userId) async {
    debugPrint('📸 Starting photo upload for user: $userId');
    
    try {
      // Validate the photo file
      if (!await photo.exists()) {
        throw Exception('Arquivo de foto não encontrado');
      }
      
      final fileSize = await photo.length();
      const maxSize = 5 * 1024 * 1024; // 5MB
      
      if (fileSize > maxSize) {
        throw Exception('Tamanho máximo da foto é de 5MB');
      }
      
      // Use the correct endpoint for uploading profile photo
      final url = Uri.parse('$_baseUrl/usuarios/$userId/foto');
      debugPrint('📤 Uploading photo to: $url');
      debugPrint('📏 File size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB');
      
      var request = http.MultipartRequest('POST', url);
      
      // Add the photo file to the request
      var photoStream = http.ByteStream(photo.openRead());
      var multipartFile = http.MultipartFile(
        'foto', // form field name as expected by the API
        photoStream,
        fileSize,
        filename: 'profile_${DateTime.now().millisecondsSinceEpoch}${photo.path.substring(photo.path.lastIndexOf('.'))}'
      );
      
      request.files.add(multipartFile);
      
      // Add any required headers
      final headers = await SafeHttp.getHeaders();
      request.headers.addAll(headers);
      
      debugPrint('🔄 Sending photo upload request...');
      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('A conexão com o servidor demorou muito. Verifique sua conexão e tente novamente.');
        },
      );
      
      var response = await http.Response.fromStream(streamedResponse);
      final responseBody = response.body;
      
      debugPrint('✅ Photo upload response status: ${response.statusCode}');
      debugPrint('📦 Response body: $responseBody');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('🎉 Photo uploaded successfully');
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        debugPrint('🔒 Authentication error (${response.statusCode})');
        throw Exception('Sessão expirada. Por favor, faça login novamente.');
      } else if (response.statusCode >= 500) {
        debugPrint('⚠️ Server error (${response.statusCode})');
        throw Exception('Erro no servidor ao enviar a foto. Tente novamente mais tarde.');
      } else {
        debugPrint('⚠️ Unexpected status code: ${response.statusCode}');
        
        // Try to parse error message from response
        try {
          final errorData = json.decode(responseBody);
          final errorMessage = errorData['message'] ?? 'Falha ao enviar a foto';
          throw Exception(errorMessage);
        } catch (e) {
          throw Exception('Falha ao enviar a foto (${response.statusCode})');
        }
      }
    } on TimeoutException catch (e) {
      debugPrint('⏱️ Timeout during photo upload: $e');
      rethrow;
    } on SocketException catch (e) {
      debugPrint('🌐 Network error during photo upload: $e');
      throw Exception('Sem conexão com a internet. Verifique sua conexão e tente novamente.');
    } catch (e) {
      debugPrint('❌ Error in uploadProfilePhoto: $e');
      rethrow;
    }
  }
}