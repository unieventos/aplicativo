import 'package:flutter/material.dart';
import 'UserRegister.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'home.dart';
import 'eventRegister.dart';

void register() {
  runApp(Register());
}

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final storage = FlutterSecureStorage();
  String? _role;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final storedRole = await storage.read(key: 'role');
    setState(() {
      _role = storedRole;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_role == null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RegisterScreen(role: _role!),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  final String role;
  RegisterScreen({required this.role});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _sobrenomeController = TextEditingController();
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _sobrenomeController.dispose();
    _loginController.dispose();
    _roleController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(flex: 3, child: Container(color: Color(0xFFCC2229))),
              Expanded(flex: 7, child: Container(color: Color(0xFFEFEFEF))),
            ],
          ),

          // Botão de voltar posicionado no topo esquerdo
          Positioned(
            top: MediaQuery.of(context).padding.top + 10, // respeita status bar
            left: 10,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => CadastroUsuarioPage()),
                );
              },
            ),
          ),

          Positioned(
            left: 20,
            right: 20,
            top: MediaQuery.of(context).size.height * 0.15,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Registro Usuário",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFCC2229)),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _nomeController,
                    autofillHints: [AutofillHints.name],
                    decoration: InputDecoration(
                      labelText: "Nome",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  SizedBox(height: 15),
                  TextField(
                    controller: _sobrenomeController,
                    autofillHints: [AutofillHints.familyName],
                    decoration: InputDecoration(
                      labelText: "Sobrenome",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  SizedBox(height: 15),
                  TextField(
                    controller: _loginController,
                    decoration: InputDecoration(
                      labelText: "Login",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  SizedBox(height: 15),
                  TextField(
                    controller: _roleController,
                    decoration: InputDecoration(
                      labelText: "Perfil",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  SizedBox(height: 15),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: [AutofillHints.email],
                    decoration: InputDecoration(
                      labelText: "E-mail",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Selecione o Curso",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: ["Ciência da Computação", "Engenharia", "Direito"]
                        .map((curso) => DropdownMenuItem(value: curso, child: Text(curso)))
                        .toList(),
                    onChanged: (value) {},
                  ),
                  SizedBox(height: 15),
                  TextField(
                    controller: _senhaController,
                    obscureText: true,
                    autofillHints: [AutofillHints.newPassword],
                    decoration: InputDecoration(
                      labelText: "Senha",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  SizedBox(height: 15),
                  TextField(
                    controller: _confirmarSenhaController,
                    obscureText: true,
                    autofillHints: [AutofillHints.newPassword],
                    decoration: InputDecoration(
                      labelText: "Confirmar Senha",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Cadastro logic here
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFCC2229),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text(
                      "CADASTRAR",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => EventosApp()));
          } else if (index == 1) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => EVRegister()));
          } else if (index == 2) {
            // já está na tela de cadastro
          } else if (index == 3) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RegisterScreen(role: widget.role)));
          }
        },
        items: widget.role == 'admin'
            ? const [
                BottomNavigationBarItem(icon: Icon(Icons.feed), label: ''),
                BottomNavigationBarItem(icon: Icon(Icons.add), label: ''),
                BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings), label: ''),
                BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
              ]
            : const [
                BottomNavigationBarItem(icon: Icon(Icons.feed), label: ''),
                BottomNavigationBarItem(icon: Icon(Icons.add), label: ''),
                BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
              ],
      ),
    );
  }
}
