import 'package:flutter/material.dart';
import 'package:flutter_application_1/home.dart';
import 'package:flutter_application_1/login.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_application_1/config/dev_flags.dart';

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
  
  Future<String?> _checkToken() async {
    return await _storage.read(key: 'token');
  }

  @override
  Widget build(BuildContext context) {
    // Em modo desenvolvimento, pula a tela de login para facilitar testes.
    if (DevFlags.skipLogin) {
      return EventosPage();
    }
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
