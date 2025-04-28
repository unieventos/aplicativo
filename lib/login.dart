import 'package:flutter/material.dart';
import 'package:flutter_application_1/register.dart';

void login() {
  runApp(Login());
}

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: LoginScreen());
  }
}

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: size.height * 0.30, // 30% da tela
            decoration: BoxDecoration(
              color: Color(0xFFCC2229),
            ),
            child: Center(
              child: Image.asset(
                'assets/logo.png',
                width: size.width * 0.9,
                height: size.height * 0.35,
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
                bottom: 20,
              ),
              child: Column(
                children: [
                  TextField(
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
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Senha",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        "Esqueceu a senha?",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown.shade700, // Tom mais escuro
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
                  SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text(
                      "CADASTRE-SE",
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
