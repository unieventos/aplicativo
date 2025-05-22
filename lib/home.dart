import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'login.dart'; // importa a sua tela de login
import 'eventRegister.dart';
import 'register.dart';
import 'modifyUser.dart';
import 'search.dart';
import 'UserRegister.dart';
import 'perfil.dart';

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

class EventosPage extends StatefulWidget {
  @override
  _EventosPageState createState() => _EventosPageState();
}

class _EventosPageState extends State<EventosPage> {
  final _storage = FlutterSecureStorage();
  String? _role;
  final bool isAdmin = true; // Altere para false se quiser simular usuário comum
  int _selectedIndex = 0; // índice de Admin alterado para 2


  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final role = await _storage.read(key: 'role');
    setState(() {
      _role = role;
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
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == _selectedIndex) return;

          if (index == 0) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => EventosApp()));
          } else if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => EVRegister()));
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => CadastroUsuarioPage()));
          } else if (index == 3) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => PerfilPage()));
          }

          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.feed,
              color: _selectedIndex == 0 ? Colors.black : Colors.grey,
              size: _selectedIndex == 0 ? 28 : 24,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.add,
              color: _selectedIndex == 1 ? Colors.black : Colors.grey,
              size: _selectedIndex == 1 ? 28 : 24,
            ),
            label: '',
          ),
          if (isAdmin)
            BottomNavigationBarItem(
              icon: Icon(
                Icons.admin_panel_settings,
                color: _selectedIndex == 2 ? Colors.black : Colors.grey,
                size: _selectedIndex == 2 ? 28 : 24,
              ),
              label: '',
            ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              color: _selectedIndex == 3 ? Colors.black : Colors.grey,
              size: _selectedIndex == 3 ? 28 : 24,
            ),
            label: '',
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
