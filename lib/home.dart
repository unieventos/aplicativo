import 'package:flutter/material.dart';
import 'login.dart'; // importa a sua tela de login
import 'eventRegister.dart';
import 'register.dart';
import 'modifyUser.dart';
import 'search.dart';

void main() => runApp(EventosApp());

class EventosApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eventos',
      debugShowCheckedModeBanner: false,
      home: EventosPage(),
    );
  }
}

class EventosPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Eventos", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.search, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SearchPage()),
            );
          },
        ),
        actions: [
          Icon(Icons.notifications_none, color: Colors.black),
          SizedBox(width: 12),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          exemploEventoCard(),
          _buildEventoCard(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Feed está selecionado
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => EventosApp()),
              (Route<dynamic> route) => false,
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EVRegister()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RegisterScreen()),
            );
          }
        },
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
    );
  }

  Widget _buildEventoCard() {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Usuário
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage('https://randomuser.me/api/portraits/men/32.jpg'), // Altere conforme necessário
                  radius: 20,
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Usuário", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("Curso", style: TextStyle(color: Colors.blue)),
                  ],
                ),
                Spacer(),
                Icon(Icons.more_vert),
              ],
            ),
            SizedBox(height: 10),

            // Texto do post
            Text(
              "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam vel orci nec libero suscipit venenatis.",
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 10),

            // Imagem do evento
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/event.png',
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 10),

            // Botões (curtir, comentar, compartilhar)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Icon(Icons.favorite_border),
                Icon(Icons.comment_outlined),
                Icon(Icons.share_outlined),
              ],
            ),
            SizedBox(height: 10),

            //Convidados
            Row(
              children: [
                SizedBox(
                  width: 110,
                  height: 32,
                  child: Stack(
                    children: List.generate(5, (index) {
                      final urls = [
                        'https://randomuser.me/api/portraits/women/30.jpg',
                        'https://randomuser.me/api/portraits/women/31.jpg',
                        'https://randomuser.me/api/portraits/women/32.jpg',
                        'https://randomuser.me/api/portraits/women/33.jpg',
                        'https://randomuser.me/api/portraits/women/34.jpg',
                      ];
                      return Positioned(
                        left: index * 20,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 15,
                            backgroundImage: NetworkImage(urls[index]),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                SizedBox(width: 24),
                Text("+150 outros", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget exemploEventoCard() {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage('https://randomuser.me/api/portraits/men/32.jpg'),
                  radius: 20,
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Exemplo Usuário", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("Exemplo Curso", style: TextStyle(color: Colors.blue)),
                  ],
                ),
                Spacer(),
                Icon(Icons.more_vert),
              ],
            ),
            SizedBox(height: 10),
            Text(
              "Este é um exemplo de card de evento.",
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                'https://img.freepik.com/fotos-premium/publico-assistindo-show-no-palco_865967-41951.jpg',
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Icon(Icons.favorite_border),
                Icon(Icons.comment_outlined),
                Icon(Icons.download),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                SizedBox(
                  width: 110,
                  height: 32,
                  child: Stack(
                    children: List.generate(5, (index) {
                      final urls = [
                        'https://randomuser.me/api/portraits/women/30.jpg',
                        'https://randomuser.me/api/portraits/women/31.jpg',
                        'https://randomuser.me/api/portraits/women/32.jpg',
                        'https://randomuser.me/api/portraits/women/33.jpg',
                        'https://randomuser.me/api/portraits/women/34.jpg',
                      ];
                      return Positioned(
                        left: index * 20,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 15,
                            backgroundImage: NetworkImage(urls[index]),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                SizedBox(width: 24),
                Text("+150 outros", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
