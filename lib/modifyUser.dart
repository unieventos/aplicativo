import 'package:flutter/material.dart';

void modify() {
  runApp(ModifyUserApp());
}

class ModifyUserApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ModifyUserScreen(
        nome: "João da Silva",
        email: "joao@email.com",
        curso: "Engenharia",
      ),
    );
  }
}

class ModifyUserScreen extends StatefulWidget {
  final String nome;
  final String email;
  final String curso;

  ModifyUserScreen({required this.nome, required this.email, required this.curso});

  @override
  _ModifyUserScreenState createState() => _ModifyUserScreenState();
}

class _ModifyUserScreenState extends State<ModifyUserScreen> {
  late TextEditingController _nomeController;
  late TextEditingController _emailController;
  late TextEditingController _senhaController;
  String? _cursoSelecionado;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.nome);
    _emailController = TextEditingController(text: widget.email);
    _senhaController = TextEditingController();
    _cursoSelecionado = widget.curso;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
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
                    "Modificar Perfil",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFCC2229)),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _nomeController,
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
                    decoration: InputDecoration(
                      labelText: "E-mail",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: _cursoSelecionado,
                    decoration: InputDecoration(
                      labelText: "Selecione o Curso",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: ["Ciência da Computação", "Engenharia", "Direito"]
                        .map((curso) => DropdownMenuItem(value: curso, child: Text(curso)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _cursoSelecionado = value;
                      });
                    },
                  ),
                  SizedBox(height: 15),
                  TextField(
                    controller: _senhaController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Nova Senha (opcional)",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Lógica para salvar alterações
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFCC2229),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text(
                      "SALVAR ALTERAÇÕES",
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
