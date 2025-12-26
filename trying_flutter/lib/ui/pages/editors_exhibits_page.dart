import 'package:flutter/material.dart';
import 'package:trying_flutter/data/exhibit_dao.dart';
import 'package:trying_flutter/data/exhibit.dart';
import 'package:intl/intl.dart';

final DateFormat _dateFormatter = DateFormat('dd.MM.yyyy');

String formatDate(DateTime? date) {
  if (date == null) return '-';
  return _dateFormatter.format(date);
}

class EditorsExhibitsPage extends StatelessWidget {
  final ExhibitDao exhibitDao;

  const EditorsExhibitsPage({
    super.key,
    required this.exhibitDao,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(title: const Text('Exhibits')),
      
      body: FutureBuilder<List<Exhibit>>(
        future: exhibitDao.getAllExhibits(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final exhibits = snapshot.data!;
          debugPrint('test');


          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: DataTable(
              columns: const [
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Title')),
                DataColumn(label: Text('Start')),
                DataColumn(label: Text('End')),
              ],
              columnSpacing: 10,
              rows: exhibits.map((e) {
                return DataRow(
                  cells: [
                    DataCell(Text(e.exhibit_id.toString())),
                    DataCell(Text(e.title)),
                    DataCell(Text(formatDate(e.startDate))),
                    DataCell(Text(formatDate(e.finalDate))),
                    //DataCell(Text(formatDate(e.startDate))),
                    //DataCell(Text(formatDate(e.finalDate))),
                  ],
                );
              }).toList(),
            ),
          );
        },
      ),
    );
    
  }
}
