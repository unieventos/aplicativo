import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/home.dart';
import 'package:flutter_application_1/screens/login.dart';
import 'package:flutter_application_1/services/user_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'config/app_theme.dart';

// Import necessário para a inicialização da formatação de datas.
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Torna a função main assíncrona para poder esperar a inicialização.
void main() async {
  // GARANTE QUE O FLUTTER ESTEJA PRONTO antes de rodar código assíncrono.
  // É uma boa prática obrigatória para main() assíncronas.
  WidgetsFlutterBinding.ensureInitialized();

  // INICIALIZA A FORMATAÇÃO DE DATAS para o português do Brasil.
  // Esta linha corrige o erro da tela vermelha.
  await initializeDateFormatting('pt_BR', null);

  runApp(const MyApp());
}

// O resto do seu código continua exatamente o mesmo.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Eventos App',
      theme: AppTheme.light(),
      home: const AuthCheck(),
    );
  }
}

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  _AuthCheckState createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true));

  Future<void> _clearSession() async {
    await _storage.delete(key: 'token');
    await _storage.delete(key: 'permanecerLogado');
    await _storage.delete(key: 'role');
  }

  Future<String?> _checkToken() async {
    final token = await _storage.read(key: 'token');
    final keepLoggedRaw = await _storage.read(key: 'permanecerLogado');

    final keepLogged =
        keepLoggedRaw != null && keepLoggedRaw.toLowerCase() == 'true';

    if (token == null || token.isEmpty) {
      return null;
    }

    // Na web (kIsWeb), um reload reseta o app, então não forçamos logout caso não tenha marcado 'Permanecer conectado'.
    if (!keepLogged && !kIsWeb) {
      await _clearSession();
      return null;
    }

    try {
      await UserService.buscarUsuario();
    } catch (_) {
      // Falha ao conectar com o servidor (ex: sem internet).
      // Não limpa o token ativo para permitir acesso offline/conectividade posterior.
    }

    return token;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _checkToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return const EventosPage();
        }

        return const LoginScreen();
      },
    );
  }
}
