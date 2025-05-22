import 'package:flutter_application_1/search.dart';
import 'package:flutter_application_1/home.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'register.dart';
import 'UserRegister.dart';
import 'perfil.dart';

class EVRegister extends StatefulWidget {
  @override
  _EVRegisterState createState() => _EVRegisterState();
}

class _EVRegisterState extends State<EVRegister> {
  String? selectedCourse;
  bool showDates = false;
  final bool isAdmin = true; // Altere para false se quiser simular usuário comum
  int _selectedIndex = 1;

  List<Map<String, DateTime?>> dateRanges = [
    {"start": null, "end": null},
    {"start": null, "end": null},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Eventos',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.search, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SearchPage()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          ),
        ],
        elevation: 0,
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Image.asset(
              'assets/event.png',
              height: 200,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Título do evento',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedCourse,
              decoration: InputDecoration(
                labelText: 'Selecione o Setor',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: ['Pastoral', 'Odontologia', 'Enfermagem', 'Ciência da Computação']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) => setState(() => selectedCourse = value),
            ),
            const SizedBox(height: 12),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Detalhes do evento',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2023),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => dateRanges[0]["start"] = picked);
                      }
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: Text(dateRanges[0]["start"] == null
                        ? 'Início'
                        : DateFormat('dd/MM/yyyy').format(dateRanges[0]["start"]!)),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.grey[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: dateRanges[0]["start"] == null
                        ? null
                        : () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: dateRanges[0]["start"]!,
                        firstDate: dateRanges[0]["start"]!,
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => dateRanges[0]["end"] = picked);
                      }
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: Text(dateRanges[0]["end"] == null
                        ? 'Fim'
                        : DateFormat('dd/MM/yyyy').format(dateRanges[0]["end"]!)),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.grey[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                // lógica para upload
              },
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload de arquivos'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => EventosApp()),
                  (Route<dynamic> route) => false,
                );
              },
              icon: Icon(Icons.description, color: Colors.white),
              label: Text('Ir para Home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // lógica para publicar evento
              },
              child: const Text(
                'PUBLICAR',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(204, 34, 41, 1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
