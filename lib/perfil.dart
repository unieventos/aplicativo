

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PerfilPage extends StatefulWidget {
  @override
  _PerfilPageState createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final storage = FlutterSecureStorage();
  String nome = '';
  String sobrenome = '';
  String email = '';
  String curso = '';
  String role = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final storedNome = await storage.read(key: 'nome') ?? '';
    final storedSobrenome = await storage.read(key: 'sobrenome') ?? '';
    final storedEmail = await storage.read(key: 'email') ?? '';
    final storedCurso = await storage.read(key: 'curso') ?? '';
    final storedRole = await storage.read(key: 'role') ?? '';

    setState(() {
      nome = storedNome;
      sobrenome = storedSobrenome;
      email = storedEmail;
      curso = storedCurso;
      role = storedRole;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil do Usuário'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nome: $nome $sobrenome', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Email: $email', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Curso: $curso', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Perfil: $role', style: TextStyle(fontSize: 18)),
            SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  await storage.deleteAll();
                  Navigator.of(context).pushReplacementNamed('/login');
                },
                child: Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}