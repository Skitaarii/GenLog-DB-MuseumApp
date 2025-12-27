// Veuillet Gaëtan
// 2025
// Description : Exhibit page adding/modifying/deleting for admin

import 'package:flutter/material.dart';
import 'package:trying_flutter/data/exhibit_dao.dart';
import 'package:trying_flutter/data/exhibit.dart';
import 'package:intl/intl.dart';

final DateFormat _dateFormatter = DateFormat('dd.MM.yyyy');

String formatDate(DateTime? date) {
  if (date == null) return '-';
  return _dateFormatter.format(date);
}

class EditorsExhibitsPage extends StatefulWidget {
  final ExhibitDao exhibitDao;

  const EditorsExhibitsPage({
    super.key,
    required this.exhibitDao,
  });

  @override
  State<EditorsExhibitsPage> createState() => _EditorsExhibitsPageState();
}

class _EditorsExhibitsPageState extends State<EditorsExhibitsPage> {
  late Future<List<Exhibit>> _exhibitsFuture;

  @override
  void initState() {
    super.initState();
    _loadExhibits();
  }

  void _loadExhibits() {
    _exhibitsFuture = widget.exhibitDao.getAllExhibits();
  }

  Future<void> _openAddExhibitDialog() async {
    final titleController = TextEditingController();
    DateTime? startDate;
    DateTime? finalDate;

    String shortDescText = '';
    String longDescText = '';

    final shortDescController = TextEditingController(text: shortDescText);
    final longDescController = TextEditingController(text: longDescText);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New exhibit'),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: shortDescController,
                    decoration: const InputDecoration(labelText: 'Short description'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: longDescController,
                    decoration: const InputDecoration(labelText: 'Long description'),
                    maxLines: 3,
                  ),
                  // DATE DÉBUT
                  ListTile(
                    title: Text(
                      startDate == null
                          ? 'Start date'
                          : 'Start : ${formatDate(startDate)}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        initialDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setDialogState(() => startDate = picked);
                      }
                    },
                  ),

                  // DATE FIN
                  ListTile(
                    title: Text(
                      finalDate == null
                          ? 'End date'
                          : 'End : ${formatDate(finalDate)}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        initialDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setDialogState(() => finalDate = picked);
                      }
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty) return;

                final short_desc = await widget.exhibitDao.getOrCreateShortDescId(shortDescController.text);
                final long_desc = await widget.exhibitDao.getOrCreateLongDescId(longDescController.text);

                await widget.exhibitDao.insertExhibit(
                  title: titleController.text,
                  startDate: startDate,
                  finalDate: finalDate,
                  shortDescId: short_desc,
                  longDescId: long_desc,

                );

                Navigator.pop(context);

                setState(() {
                  _loadExhibits();
                });
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openEditDialog(Exhibit exhibit) async {
    final titleController = TextEditingController(text: exhibit.title);
    DateTime? startDate = exhibit.startDate;
    DateTime? finalDate = exhibit.finalDate;

    String shortDescText = '';
    String longDescText = '';

    final shortResult = await widget.exhibitDao.connection.query(
      'SELECT en FROM short_desc WHERE id = @id',
      substitutionValues: {'id': exhibit.short_desc_id},
    );
    if (shortResult.isNotEmpty) shortDescText = shortResult.first[0] as String;

    final longResult = await widget.exhibitDao.connection.query(
      'SELECT en FROM long_desc WHERE id = @id',
      substitutionValues: {'id': exhibit.long_desc_id},
    );
    if (longResult.isNotEmpty) longDescText = longResult.first[0] as String;

    final shortDescController = TextEditingController(text: shortDescText);
    final longDescController = TextEditingController(text: longDescText);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit exhibit'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 300,
              maxWidth: 700,
              minHeight: 400,
              maxHeight: 600, // un peu plus grand
            ),
            child: StatefulBuilder(
              builder: (context, setDialogState) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: 'Title'),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: shortDescController,
                        decoration: const InputDecoration(labelText: 'Short description'),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: longDescController,
                        decoration: const InputDecoration(labelText: 'Long description'),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        title: Text(
                          startDate == null
                              ? 'Start date'
                              : 'Start : ${formatDate(startDate)}',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                            initialDate: startDate ?? DateTime.now(),
                          );
                          if (picked != null) {
                            setDialogState(() => startDate = picked);
                          }
                        },
                      ),
                      const SizedBox(height: 4),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        title: Text(
                          finalDate == null
                              ? 'End date'
                              : 'End : ${formatDate(finalDate)}',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                            initialDate: finalDate ?? DateTime.now(),
                          );
                          if (picked != null) {
                            setDialogState(() => finalDate = picked);
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await widget.exhibitDao.update(
                  exhibitId: exhibit.exhibit_id,
                  title: titleController.text,
                  startDate: startDate!,
                  finalDate: finalDate!,
                  shortDesc: shortDescController.text,
                  longDesc: longDescController.text,
                );

                Navigator.pop(context);
                setState(() => _loadExhibits());
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }


  Future<void> _deleteExhibit(Exhibit exhibit) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete'),
      content: Text('Delete "${exhibit.title}" ?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Delete'),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    await widget.exhibitDao.deleteExhibit(exhibit.exhibit_id);
    setState(() => _loadExhibits());
  }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exhibits')),
      body: FutureBuilder<List<Exhibit>>(
        future: _exhibitsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final exhibits = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ADD BUTTON
                ElevatedButton.icon(
                  onPressed: _openAddExhibitDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Add an exhibit'),
                ),
                const SizedBox(height: 16),

                // TABLE
                DataTable(
                  columns: const [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Title')),
                    //DataColumn(label: Text('End')),
                    DataColumn(label: Text('Edit')),
                    DataColumn(label: Text('Delete')),
                  ],
                  rows: exhibits.map((e) {
                    return DataRow(
                      cells: [
                        DataCell(Text(e.exhibit_id.toString())),
                        DataCell(Text(e.title)),
                        //DataCell(Text(formatDate(e.finalDate))),

                        //EDIT
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _openEditDialog(e),
                          ),
                        ),

                        //DELETE
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteExhibit(e),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
