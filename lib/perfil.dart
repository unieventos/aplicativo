

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

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
    final storedNome = utf8.decode((await storage.read(key: 'nome'))?.codeUnits ?? []);
    final storedSobrenome = utf8.decode((await storage.read(key: 'sobrenome'))?.codeUnits ?? []);
    final storedEmail = utf8.decode((await storage.read(key: 'email'))?.codeUnits ?? []);
    final storedCurso = utf8.decode((await storage.read(key: 'cursoId'))?.codeUnits ?? []);
    final storedRole = utf8.decode((await storage.read(key: 'role'))?.codeUnits ?? []);

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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.person),
                      title: Text('$nome $sobrenome', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      subtitle: Text('Nome completo'),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.email),
                      title: Text(email, style: TextStyle(fontSize: 18)),
                      subtitle: Text('Email'),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.school),
                      title: Text(curso, style: TextStyle(fontSize: 18)),
                      subtitle: Text('Curso'),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.admin_panel_settings),
                      title: Text(role, style: TextStyle(fontSize: 18)),
                      subtitle: Text('Perfil'),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () async {
                await storage.deleteAll();
                Navigator.of(context).pushReplacementNamed('/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: Icon(Icons.logout, color: Colors.white),
              label: Text('Logout', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}