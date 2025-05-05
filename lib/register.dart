import 'package:flutter/material.dart';

void register() {
  runApp(Register());
}

class Register extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: RegisterScreen());
  }
}

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
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
                    "Cadastre-se",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFCC2229)),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _nomeController,
                    autofillHints: [AutofillHints.name],
                    decoration: InputDecoration(
                      labelText: "Nome Completo",
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
                      TextInput.finishAutofillContext();
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
    );
  }
}
