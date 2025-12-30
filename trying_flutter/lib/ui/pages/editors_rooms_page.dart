// Veuillet Gaëtan
// 2025
// Description : Room page adding/modifying/deleting for admin

import 'package:flutter/material.dart';
import 'package:trying_flutter/data/room_dao.dart';
import 'package:trying_flutter/data/room.dart';
import 'package:intl/intl.dart';


final DateFormat _dateFormatter = DateFormat('dd.MM.yyyy');

String formatDate(DateTime? date) {
  if (date == null) return '-';
  return _dateFormatter.format(date);
}

class EditorsRoomsPage extends StatefulWidget {
  final RoomDao roomDao;

  const EditorsRoomsPage({
    super.key,
    required this.roomDao,
  });

  @override
  State<EditorsRoomsPage> createState() => _EditorsRoomsPageState();
}

class _EditorsRoomsPageState extends State<EditorsRoomsPage> {
  late Future<List<RoomWithExhibits>> _roomsFuture;

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  void _loadRooms() {
    _roomsFuture = widget.roomDao.getRoomsWithExhibits();
  }

Future<void> _openAddRoomDialog() async {
  final name = TextEditingController();

  // fetch exhibits for the dropdown / multi-select
  final availableExhibits = await widget.roomDao.getAllExhibits();
  final selected = <int>{};

  await showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 400,
            maxHeight: 600,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'New room',
                  style: Theme.of(context).textTheme.titleLarge, // Changé ici
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: name,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Select exhibits:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      if (availableExhibits.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Text('No exhibits available'),
                        )
                      else
                        StatefulBuilder(
                          builder: (context, setDialogState) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: availableExhibits.map((ex) {
                                final isSelected = selected.contains(ex.exhibit_id);
                                return CheckboxListTile(
                                  title: Text(ex.title),
                                  value: isSelected,
                                  onChanged: (v) => setDialogState(() {
                                    if (v == true) {
                                      selected.add(ex.exhibit_id);
                                    } else {
                                      selected.remove(ex.exhibit_id);
                                    }
                                  }),
                                );
                              }).toList(),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        if (name.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a room name'),
                            ),
                          );
                          return;
                        }

                        final newRoomId = await widget.roomDao.insertRoom(name: name.text);
                        if (selected.isNotEmpty) {
                          await widget.roomDao.insertRoomExhibits(newRoomId, selected.toList());
                        }

                        Navigator.pop(context);
                        setState(() {
                          _loadRooms();
                        });
                      },
                      child: const Text('Create'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> _openEditDialog(RoomWithExhibits room) async {
  final name = TextEditingController(text: room.name);
  
  // fetch exhibits for the dropdown / multi-select
  final availableExhibits = await widget.roomDao.getAllExhibits();
  final selected = <int>{...room.exhibits.map((e) => e.exhibit_id)};

  await showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 400,
            maxHeight: 600,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Edit room',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: name,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Select exhibits:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      if (availableExhibits.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Text('No exhibits available'),
                        )
                      else
                        StatefulBuilder(
                          builder: (context, setDialogState) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: availableExhibits.map((ex) {
                                final isSelected = selected.contains(ex.exhibit_id);
                                return CheckboxListTile(
                                  title: Text(ex.title),
                                  value: isSelected,
                                  onChanged: (v) => setDialogState(() {
                                    if (v == true) {
                                      selected.add(ex.exhibit_id);
                                    } else {
                                      selected.remove(ex.exhibit_id);
                                    }
                                  }),
                                );
                              }).toList(),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        if (name.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a room name'),
                            ),
                          );
                          return;
                        }

                        //Update room name
                        await widget.roomDao.updateRoom(room.room_id, name: name.text);
                        
                        //Update exhibits list
                        await widget.roomDao.updateRoomExhibits(room.room_id, selected.toList());

                        Navigator.pop(context);
                        setState(() {
                          _loadRooms();
                        });
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

  Future<void> _deleteExhibit(RoomWithExhibits room) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete'),
      content: Text('Delete "${room.name}" ?'),
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
    await widget.roomDao.deleteRoom(room.room_id);
    setState(() => _loadRooms());
  }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rooms')),
      body: FutureBuilder<List<RoomWithExhibits>>(
        future: _roomsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final rooms = snapshot.data!;

          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ADD BUTTON
                      ElevatedButton.icon(
                        onPressed: _openAddRoomDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Add a room'),
                      ),
                      const SizedBox(height: 16),

                      // TABLEwith table widget
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Table(
                          border: TableBorder(
                            horizontalInside: BorderSide(color: Colors.grey[300]!),
                            verticalInside: BorderSide(color: Colors.grey[300]!),
                          ),
                          columnWidths: const {
                            0: FlexColumnWidth(2),
                            1: FlexColumnWidth(3),
                            2: FixedColumnWidth(80),
                            3: FixedColumnWidth(80),
                          },
                          children: [
                            // Header row
                            TableRow(
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                              ),
                              children: const [
                                Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Text('Exhibits', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Text('Edit', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Text('Delete', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                                ),
                              ],
                            ),
                            // Data rows
                            ...rooms.map((r) {
                              return TableRow(
                                children: [
                                  // Name
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    alignment: Alignment.centerLeft,
                                    child: Text(r.name),
                                  ),
                                  // Exhibits
                                  Container(
                                    constraints: const BoxConstraints(
                                      minHeight: 60,
                                    ),
                                    padding: const EdgeInsets.all(12),
                                    alignment: Alignment.centerLeft,
                                    child: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (r.exhibits.isEmpty)
                                            const Text('No exhibits',
                                                style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))
                                          else
                                            ...r.exhibits.map((ex) => Padding(
                                                  padding: const EdgeInsets.only(bottom: 4),
                                                  child: Text('• ${ex.title}'),
                                                )),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Edit
                                  Container(
                                    height: 60,
                                    alignment: Alignment.center,
                                    child: IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () => _openEditDialog(r),
                                    ),
                                  ),
                                  // Delete
                                  Container(
                                    height: 60,
                                    alignment: Alignment.center,
                                    child: IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteExhibit(r),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}