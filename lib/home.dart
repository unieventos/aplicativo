import 'package:flutter/material.dart';
import 'login.dart'; // importa a sua tela de login
import 'eventRegister.dart';
import 'register.dart';
import 'modifyUser.dart';

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
        leading: Icon(Icons.arrow_back_ios, color: Colors.black),
        actions: [
          Icon(Icons.notifications_none, color: Colors.black),
          SizedBox(width: 12),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildEventoCard(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.grey,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EventPage()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EventPage()),
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
            icon: Icon(Icons.feed, color: Colors.grey),
            label: "Feeds",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add, color: Colors.grey),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.grey),
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
                  backgroundImage: AssetImage('assets/avatar.jpg'), // Altere conforme necessário
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
              child: Image.network(
                'https://img.freepik.com/fotos-premium/publico-assistindo-show-no-palco_865967-41951.jpg',
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

            // Convidados
            Row(
              children: [
                Stack(
                  children: List.generate(5, (index) {
                    return Positioned(
                      left: index * 20,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 15,
                          backgroundImage: AssetImage('assets/avatar.jpg'), // Use diferentes imagens se quiser
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(width: 120),
                Text("+150 outros", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
