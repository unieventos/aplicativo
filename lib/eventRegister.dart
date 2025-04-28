import 'package:flutter/material.dart';

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
        title: Text('Eventos'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none),
            onPressed: () {},
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.feed), label: 'Feeds'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: 1,
        onTap: (index) {
          // Navegação entre abas
        },
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Image.asset(
              'assets/event_image.png',
              height: 200,
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Título do evento',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedCourse,
              decoration: InputDecoration(
                labelText: 'Selecione o Curso',
                border: OutlineInputBorder(),
              ),
              items: ['ADS', 'Direito', 'Enfermagem']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) => setState(() => selectedCourse = value),
            ),
            SizedBox(height: 12),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Detalhes do evento',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            CheckboxListTile(
              title: Text('Datas específicas'),
              value: showDates,
              onChanged: (value) => setState(() => showDates = value!),
            ),
            if (showDates)
              ...dateRanges.map((range) => Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2023),
                          lastDate: DateTime(2100),
                        );
                        setState(() => range["start"] = picked);
                      },
                      child: Text(range["start"] == null
                          ? 'Início'
                          : '${range["start"]!.day}/${range["start"]!.month}'),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2023),
                          lastDate: DateTime(2100),
                        );
                        setState(() => range["end"] = picked);
                      },
                      child: Text(range["end"] == null
                          ? 'Fim'
                          : '${range["end"]!.day}/${range["end"]!.month}'),
                    ),
                  ),
                ],
              )),
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                // lógica para upload
              },
              icon: Icon(Icons.upload_file),
              label: Text('Upload de arquivos'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // lógica para publicar evento
              },
              child: Text('PUBLICAR'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
