import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: CadastroUsuarioPage(),
  ));
}

class Usuario {
  final String nome;
  final String email;
  bool expandido;

  Usuario(this.nome, this.email, {this.expandido = false});
}

class CadastroUsuarioPage extends StatefulWidget {
  @override
  _CadastroUsuarioPageState createState() => _CadastroUsuarioPageState();
}

class _CadastroUsuarioPageState extends State<CadastroUsuarioPage> {
  List<Usuario> usuarios = [
    Usuario("João Siiva", "joao@email.com"),
    Usuario("María Oliveira", "maria@email.com"),
    Usuario("Carla Souza", "carla@email.com"),
    Usuario("Pedro Santos", "pedro@email.com"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cadastro Usuario",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: usuarios.length,
        itemBuilder: (context, index) {
          final usuario = usuarios[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Column(
              children: [
                ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(usuario.nome),
                  subtitle: Text(usuario.email),
                  trailing: IconButton(
                    icon: Icon(
                      usuario.expandido
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                    ),
                    onPressed: () {
                      setState(() {
                        usuario.expandido = !usuario.expandido;
                      });
                    },
                  ),
                ),
                if (usuario.expandido)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            // ação de modificar
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text("Modificar"),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              usuarios.removeAt(index);
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          icon: const Icon(Icons.delete),
                          label: const Text("Deletar"),
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.feed),
            label: "Feeds",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 60),
        child: ElevatedButton(
          onPressed: () {
            // ação para adicionar novo usuário
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          ),
          child: const Text("Novo Usuario",
            style: TextStyle(color: Colors.white),),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
