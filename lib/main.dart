import 'package:flutter/material.dart';
import 'package:flutter_application_1/home.dart';
import 'package:flutter_application_1/login.dart';
import 'package:flutter_application_1/user_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Import necessário para a inicialização da formatação de datas.
import 'package:intl/date_symbol_data_local.dart';

// Torna a função main assíncrona para poder esperar a inicialização.
void main() async {
  // GARANTE QUE O FLUTTER ESTEJA PRONTO antes de rodar código assíncrono.
  // É uma boa prática obrigatória para main() assíncronas.
  WidgetsFlutterBinding.ensureInitialized();
  
  // INICIALIZA A FORMATAÇÃO DE DATAS para o português do Brasil.
  // Esta linha corrige o erro da tela vermelha.
  await initializeDateFormatting('pt_BR', null);
  
  runApp(MyApp());
}

// O resto do seu código continua exatamente o mesmo.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Eventos App',
      theme: ThemeData(
        primaryColor: Color(0xFFCC2229),
        colorScheme: ColorScheme.light(
          primary: Color(0xFFCC2229),
          secondary: Color(0xFF6D4C41),
        ),
        scaffoldBackgroundColor: Color(0xFFF5F5F5),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
        ),
      ),
      home: AuthCheck(),
    );
  }
}

class AuthCheck extends StatefulWidget {
  @override
  _AuthCheckState createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  final _storage = FlutterSecureStorage();
  
  Future<void> _clearSession() async {
    await _storage.delete(key: 'token');
    await _storage.delete(key: 'permanecerLogado');
    await _storage.delete(key: 'role');
  }

  Future<String?> _checkToken() async {
    final token = await _storage.read(key: 'token');
    final keepLoggedRaw = await _storage.read(key: 'permanecerLogado');

    final keepLogged = keepLoggedRaw != null &&
        keepLoggedRaw.toLowerCase() == 'true';

    if (token == null || token.isEmpty || !keepLogged) {
      await _clearSession();
      return null;
    }

    try {
      final userId = await UserService.buscarUsuario();
      if (userId == null) {
        await _clearSession();
        return null;
      }
      return token;
    } catch (_) {
      await _clearSession();
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _checkToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return EventosPage();
        }
        
        return LoginScreen();
      },
    );
  }
}
