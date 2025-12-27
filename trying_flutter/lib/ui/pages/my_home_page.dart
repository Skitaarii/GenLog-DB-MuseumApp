import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:trying_flutter/data/exhibit_dao.dart';
import 'package:trying_flutter/ui/pages/editors_home_page.dart';
//import 'qrcode_page.dart'; // ici QRViewExample est défini

class MyHomePage extends StatefulWidget {
  final String title;
  final ExhibitDao exhibitDao;

  const MyHomePage({
    super.key,
    required this.title,
    required this.exhibitDao,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  final _titleController = TextEditingController();
  final _startController = TextEditingController();
  final _finalController = TextEditingController();

  Future<void> _incrementCounter() async {
    try {
      await widget.exhibitDao.insertExhibit(
        title: 'BENNO EXHIBIT',
        startDate: DateTime(2024, 6, 1),
        finalDate: DateTime(2024, 12, 31),
      );

      await widget.exhibitDao.update(
        exhibitId: 1,
        title: 'BENNO EXHIBIT UPDATED',
        startDate: DateTime(2025, 1, 1),
        finalDate: DateTime(2026, 1, 31),
      );

      final result = await widget.exhibitDao.getExhibitById(1);
      debugPrint('Query results: $result');

      setState(() => _counter++);
    } catch (e, st) {
      debugPrint('DB error: $e');
      debugPrintStack(stackTrace: st);
    }
  }

  Future<void> _submitForm() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    await widget.exhibitDao.insertExhibit(
      title: title,
      startDate: _startController.text.isEmpty
          ? null
          : DateTime.parse(_startController.text),
      finalDate: _finalController.text.isEmpty
          ? null
          : DateTime.parse(_finalController.text),
    );

    _titleController.clear();
    _startController.clear();
    _finalController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Text('$_counter'),
          TextField(controller: _titleController),
          TextField(controller: _startController),
          TextField(controller: _finalController),
          ElevatedButton(
            onPressed: _submitForm,
            child: const Text('Submit'),
          ),
          const SizedBox(height: 20),
          //bouton pour aller sur la page caméra
          ElevatedButton(
            onPressed: () {
              print("Navigating to Camera Page");
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditorsHomePage(
                  exhibitDao: widget.exhibitDao,
                )),
              );
            },
            child: const Text('Go to editor page'),
          ),
        ],
      ),
    );
  }
}
