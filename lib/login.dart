import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/home.dart';
import 'package:flutter_application_1/register.dart';
import 'package:flutter_application_1/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_application_1/search.dart';
import 'package:flutter_application_1/user_service.dart';

void login() {
  runApp(Login());
}

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  bool _permanecerLogado = false;

  final storage = FlutterSecureStorage();

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(
            height: size.height * 0.30,
            decoration: BoxDecoration(
              color: Color(0xFFCC2229),
            ),
            child: Align(
              alignment: Alignment(0, 1.0),
              child: Image.asset(
                'assets/logo.png',
                width: size.width * 1.1,
                height: size.height * 1.1,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                top: size.height * 0.30 + 20,
                left: 32,
                right: 32,
                bottom: 10,
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: [AutofillHints.username, AutofillHints.email],
                    decoration: InputDecoration(
                      labelText: "Usuário",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  SizedBox(height: 15),
                  TextField(
                    controller: _senhaController,
                    obscureText: true,
                    autofillHints: [AutofillHints.password],
                    decoration: InputDecoration(
                      labelText: "Senha",
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey, width: 2),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Checkbox(
                        value: _permanecerLogado,
                        onChanged: (bool? value) {
                          setState(() {
                            _permanecerLogado = value ?? false;
                          });
                        },
                      ),
                      Text("Permanecer logado"),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      TextInput.finishAutofillContext();

                      final token = await AuthService.fazerLogin(
                        _emailController.text.trim(),
                        _senhaController.text.trim(),
                        _permanecerLogado
                      );

                      if (token != null) {
                        await storage.write(key: 'token', value: token);
                        await storage.write(key: 'permanecerLogado', value: _permanecerLogado.toString());
                        await storage.write(key: 'role', value: 'ADMIN');

                        UserService.buscarUsuario();
                        // Aqui você pode redirecionar para a próxima tela
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => EventosApp()),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Login ou Senha inválidos',
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Color(0xFFCC2229),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text(
                      "LOGIN",
                      
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Nova tela de cadastro
