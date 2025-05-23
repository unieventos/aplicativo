import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/register.dart';
import 'package:flutter_application_1/UserRegister.dart';
import 'package:flutter_application_1/eventRegister.dart';
import 'package:flutter_application_1/login.dart';
import 'package:flutter_application_1/home.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'login.dart'; // importa a sua tela de login
import 'eventRegister.dart';
import 'register.dart';
import 'modifyUser.dart';
import 'search.dart';
import 'UserRegister.dart';
import 'perfil.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'login.dart'; // importa a sua tela de login
import 'eventRegister.dart';
import 'register.dart';
import 'modifyUser.dart';
import 'home.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'perfil.dart';

void main() {
  runApp(MaterialApp(
    home: SearchPage(),
    debugShowCheckedModeBanner: false,
  ));
}

class Evento {
  final String nome;
  final String tipo;
  final String resumo;

  Evento(this.nome, this.tipo, this.resumo);
}

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final storage = FlutterSecureStorage();
  String? _role;
  final bool isAdmin = true; // Altere para false se quiser simular usuário comum

  List<Evento> eventos = [
    Evento("NOME DO EVENTO", "CURSO", "BREVE RESUMO DO ENVENTO AQUI, SEM SER MUIT DETALHADO, CONTENDO INFO RELEVANTE"),
    Evento("NOME DO EVENTO", "CURSO", "BREVE RESUMO DO ENVENTO AQUI, SEM SER MUIT DETALHADO, CONTENDO INFO RELEVANTE"),
    Evento("WORKSHOP DE DESIGN", "WORKSHOP", "APRENDA FUNDAMENTOS DE DESIGN EM UM DIA INTENSIVO DE CONTEÚDO."),
    Evento("PALESTRA SOBRE IA", "PALESTRA", "DISCUSSÃO SOBRE OS IMPACTOS E FUTURO DA INTELIGÊNCIA ARTIFICIAL."),
    Evento("MARATONA DE PROGRAMAÇÃO", "COMPETIÇÃO", "EVENTO PARA DESENVOLVEDORES MOSTRAREM SUAS HABILIDADES."),
    Evento("ENCONTRO DE STARTUPS", "NETWORKING", "OPORTUNIDADE PARA EMPREENDEDORES APRESENTAREM SUAS IDEIAS."),
    Evento("FESTIVAL DE TECNOLOGIA", "FEIRA", "FEIRA COM STANDS, PALESTRAS E LANÇAMENTOS DE PRODUTOS TECH."),
  ];

  List<bool> expandido = [];
  Set<int> selecionados = {};

  @override
  void initState() {
    super.initState();
    expandido = List<bool>.filled(eventos.length, false);
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
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Eventos", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              if (selecionados.isEmpty) return;
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) {
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Selecionados: ${selecionados.length}",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        if (selecionados.length <= 3)
                          ListTile(
                            leading: const Icon(Icons.download),
                            title: const Text("Baixar relatório"),
                            onTap: () {
                              Navigator.pop(context);
                              // lógica de download
                            },
                          ),
                        ListTile(
                          leading: const Icon(Icons.email),
                          title: const Text("Enviar por e-mail"),
                          onTap: () {
                            Navigator.pop(context);
                            // lógica de envio por e-mail
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            icon: const Icon(Icons.send, color: Colors.black),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications, color: Colors.black),
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.search, color: Colors.black),
          onPressed: () {},
        ),
      ),
      body: ListView.builder(
        itemCount: eventos.length,
        itemBuilder: (context, index) {
          final evento = eventos[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.celebration, color: Colors.deepPurple),
                  title: Text(evento.nome),
                  subtitle: Text(evento.tipo),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: selecionados.contains(index),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              selecionados.add(index);
                            } else {
                              selecionados.remove(index);
                            }
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          expandido[index] ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        ),
                        onPressed: () {
                          setState(() {
                            expandido[index] = !expandido[index];
                          });
                        },
                      ),
                    ],
                  ),
                ),
                if (expandido[index])
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(evento.resumo),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 80,
                          height: 80,
                          color: Colors.red.shade700,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
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
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CadastroUsuarioPage()));
          } else if (index == 3) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PerfilPage()));
          }

        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.feed,
              color: Colors.grey,
              size: 24,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.add,
              color: Colors.grey,
              size: 24,
            ),
            label: '',
          ),
          if (isAdmin)
            BottomNavigationBarItem(
              icon: Icon(
                Icons.admin_panel_settings,
                color: Colors.grey,
                size: 24,
              ),
              label: '',
            ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              color: Colors.grey,
              size: 24,
            ),
            label: '',
          ),
        ],
      ),
    );
  }
}
