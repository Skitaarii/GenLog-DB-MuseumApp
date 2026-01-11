// Veuillet Gaëtan
// 2025
// Description : Room page adding/modifying/deleting for editor

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
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
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
                  'New Room',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Divider(color: Colors.purple[700]),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: name,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Room Name',
                          labelStyle: TextStyle(color: Colors.grey[400]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.purple[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.purple[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.purpleAccent),
                          ),
                          filled: true,
                          fillColor: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Select exhibits:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      if (availableExhibits.isEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'No exhibits available',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        )
                      else
                        Container(
                          constraints: const BoxConstraints(maxHeight: 200),
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.purple[700]!),
                          ),
                          child: StatefulBuilder(
                            builder: (context, setDialogState) {
                              return ListView.builder(
                                shrinkWrap: true,
                                itemCount: availableExhibits.length,
                                itemBuilder: (context, i) {
                                  final ex = availableExhibits[i];
                                  final isSelected = selected.contains(ex.exhibit_id);
                                  return Container(
                                    decoration: BoxDecoration(
                                      border: i < availableExhibits.length - 1
                                          ? Border(
                                              bottom: BorderSide(color: Colors.grey[700]!),
                                            )
                                          : null,
                                    ),
                                    child: CheckboxListTile(
                                      title: Text(
                                        ex.title,
                                        style: TextStyle(
                                          color: isSelected ? Colors.white : Colors.grey[300],
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                      value: isSelected,
                                      onChanged: (v) => setDialogState(() {
                                        if (v == true) {
                                          selected.add(ex.exhibit_id);
                                        } else {
                                          selected.remove(ex.exhibit_id);
                                        }
                                      }),
                                      activeColor: Colors.purple,
                                      checkColor: Colors.white,
                                      tileColor: Colors.transparent,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Divider(color: Colors.purple[700]),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.purple[700]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: Colors.purple[300]),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.purple[700]!,
                            Colors.deepPurple[700]!,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          if (name.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter a room name'),
                                backgroundColor: Colors.red,
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        child: const Text(
                          'Create',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
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
                  'Edit Room',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Divider(color: Colors.purple[700]),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: name,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Room Name',
                          labelStyle: TextStyle(color: Colors.grey[400]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.purple[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.purple[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.purpleAccent),
                          ),
                          filled: true,
                          fillColor: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Select exhibits:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      if (availableExhibits.isEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'No exhibits available',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        )
                      else
                        Container(
                          constraints: const BoxConstraints(maxHeight: 200),
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.purple[700]!),
                          ),
                          child: StatefulBuilder(
                            builder: (context, setDialogState) {
                              return ListView.builder(
                                shrinkWrap: true,
                                itemCount: availableExhibits.length,
                                itemBuilder: (context, i) {
                                  final ex = availableExhibits[i];
                                  final isSelected = selected.contains(ex.exhibit_id);
                                  return Container(
                                    decoration: BoxDecoration(
                                      border: i < availableExhibits.length - 1
                                          ? Border(
                                              bottom: BorderSide(color: Colors.grey[700]!),
                                            )
                                          : null,
                                    ),
                                    child: CheckboxListTile(
                                      title: Text(
                                        ex.title,
                                        style: TextStyle(
                                          color: isSelected ? Colors.white : Colors.grey[300],
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                      value: isSelected,
                                      onChanged: (v) => setDialogState(() {
                                        if (v == true) {
                                          selected.add(ex.exhibit_id);
                                        } else {
                                          selected.remove(ex.exhibit_id);
                                        }
                                      }),
                                      activeColor: Colors.purple,
                                      checkColor: Colors.white,
                                      tileColor: Colors.transparent,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Divider(color: Colors.purple[700]),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.purple[700]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: Colors.purple[300]),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.purple[700]!,
                            Colors.deepPurple[700]!,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          if (name.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter a room name'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          // Update room name
                          await widget.roomDao.updateRoom(room.room_id, name: name.text);
                          
                          // Update exhibits list
                          await widget.roomDao.updateRoomExhibits(room.room_id, selected.toList());

                          Navigator.pop(context);
                          setState(() {
                            _loadRooms();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        child: const Text(
                          'Save',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
        backgroundColor: Colors.grey[900],
        title: const Text('Delete Room', style: TextStyle(color: Colors.white)),
        content: Text(
          'Delete "${room.name}"? This will also remove all exhibit associations.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.purpleAccent)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Rooms Management',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<RoomWithExhibits>>(
        future: _roomsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          final rooms = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ADD BUTTON
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.purple[700]!,
                        Colors.deepPurple[700]!,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.4),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _openAddRoomDialog,
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      'Add New Room',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // TABLE
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.purple[800]!),
                  ),
                  child: Table(
                    border: TableBorder(
                      horizontalInside: BorderSide(color: Colors.grey[800]!),
                      verticalInside: BorderSide(color: Colors.grey[800]!),
                      borderRadius: BorderRadius.circular(12),
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
                          color: Colors.purple[900],
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(12),
                            child: Text(
                              'Room Name',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(12),
                            child: Text(
                              'Exhibits',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(12),
                            child: Text(
                              'Edit',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(12),
                            child: Text(
                              'Delete',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      // Data rows
                      ...rooms.map((r) {
                        return TableRow(
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                          ),
                          children: [
                            // Name
                            Container(
                              padding: const EdgeInsets.all(12),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                r.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
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
                                      Text(
                                        'No exhibits assigned',
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontStyle: FontStyle.italic,
                                        ),
                                      )
                                    else
                                      ...r.exhibits.map((ex) => Padding(
                                            padding: const EdgeInsets.only(bottom: 6),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.arrow_forward_ios,
                                                  size: 10,
                                                  color: Colors.purple[300],
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    ex.title,
                                                    style: const TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 12,
                                                    ),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
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
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Statistiques
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.purple[800]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Rooms',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[400],
                            ),
                          ),
                          Text(
                            rooms.length.toString(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Exhibits',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[400],
                            ),
                          ),
                          Text(
                            rooms.fold(0, (sum, room) => sum + room.exhibits.length).toString(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.room,
                        size: 40,
                        color: Colors.purple[300],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}