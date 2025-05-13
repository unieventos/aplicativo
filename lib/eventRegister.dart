import 'package:flutter_application_1/search.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventPage extends StatefulWidget {
  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  String? selectedCourse;
  bool showDates = false;

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
              MaterialPageRoute(builder: (context) => EventosPage()),
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
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(icon: const Icon(Icons.feed, color: Colors.blue), onPressed: () {}),
            const SizedBox(width: 40), // espaço para o FAB
            IconButton(icon: const Icon(Icons.person), onPressed: () {}),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
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
                        ? null // desativa o botão se a data de início for nula
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
