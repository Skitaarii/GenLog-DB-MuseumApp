// Veuillet Gaëtan
// 2025
// Description : Exhibit page adding/modifying/deleting for admin

import 'package:flutter/material.dart';
import 'package:editor_app/data/exhibit_dao.dart';
import 'package:editor_app/data/exhibit.dart';
import 'package:intl/intl.dart';
import 'package:editor_app/utils/qr_code_helper.dart';


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
        return Dialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: StatefulBuilder(
            builder: (context, setDialogState) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'New Exhibit',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Divider(color: Colors.purple[700]),
                    const SizedBox(height: 16),
                    
                    // Champs de saisie
                    TextField(
                      controller: titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Title',
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
                    const SizedBox(height: 16),
                    
                    TextField(
                      controller: shortDescController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Short description',
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
                    const SizedBox(height: 16),
                    
                    TextField(
                      controller: longDescController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Long description',
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
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),

                    // Dates
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.purple[700]!),
                      ),
                      child: Column(
                        children: [
                          GestureDetector(
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
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[900],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    color: Colors.purple[300],
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      startDate == null
                                          ? 'Select start date'
                                          : 'Start: ${formatDate(startDate)}',
                                      style: TextStyle(
                                        color: startDate == null
                                            ? Colors.grey[500]
                                            : Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          GestureDetector(
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
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[900],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    color: Colors.purple[300],
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      finalDate == null
                                          ? 'Select end date'
                                          : 'End: ${formatDate(finalDate)}',
                                      style: TextStyle(
                                        color: finalDate == null
                                            ? Colors.grey[500]
                                            : Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Boutons
                    Row(
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
                              if (titleController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please enter a title'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

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
                  ],
                ),
              );
            },
          ),
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
        return Dialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: StatefulBuilder(
            builder: (context, setDialogState) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Edit Exhibit',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Divider(color: Colors.purple[700]),
                    const SizedBox(height: 16),
                    
                    SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: titleController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Title',
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
                          const SizedBox(height: 16),
                          
                          TextField(
                            controller: shortDescController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Short description',
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
                          const SizedBox(height: 16),
                          
                          TextField(
                            controller: longDescController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Long description',
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
                            maxLines: 3,
                          ),
                          const SizedBox(height: 20),

                          // Dates
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.purple[700]!),
                            ),
                            child: Column(
                              children: [
                                GestureDetector(
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
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[900],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          color: Colors.purple[300],
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            startDate == null
                                                ? 'Select start date'
                                                : 'Start: ${formatDate(startDate)}',
                                            style: TextStyle(
                                              color: startDate == null
                                                  ? Colors.grey[500]
                                                  : Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                
                                GestureDetector(
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
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[900],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          color: Colors.purple[300],
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            finalDate == null
                                                ? 'Select end date'
                                                : 'End: ${formatDate(finalDate)}',
                                            style: TextStyle(
                                              color: finalDate == null
                                                  ? Colors.grey[500]
                                                  : Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Boutons
                    Row(
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
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _deleteExhibit(Exhibit exhibit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Delete Exhibit', style: TextStyle(color: Colors.white)),
        content: Text(
          'Delete "${exhibit.title}"? This action cannot be undone.',
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
      await widget.exhibitDao.deleteExhibit(exhibit.exhibit_id);
      setState(() => _loadExhibits());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Exhibits Management',
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
      body: FutureBuilder<List<Exhibit>>(
        future: _exhibitsFuture,
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

          final exhibits = snapshot.data!;

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
                    onPressed: _openAddExhibitDialog,
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      'Add New Exhibit',
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
                      0: FixedColumnWidth(60),
                      1: FlexColumnWidth(3),
                      2: FixedColumnWidth(80),
                      3: FixedColumnWidth(80),
                      4: FixedColumnWidth(80),
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
                            child: Text('ID', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(12),
                            child: Text('Title', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(12),
                            child: Text(
                              'QR',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(12),
                            child: Text(
                              'Edit',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(12),
                            child: Text(
                              'Delete',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),

                      
                      // Data rows
                      ...exhibits.map((e) {
                        return TableRow(
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                          ),
                          children: [
                            // ID
                            Container(
                              padding: const EdgeInsets.all(12),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '#${e.exhibit_id}',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // Title
                            Container(
                              padding: const EdgeInsets.all(12),
                              alignment: Alignment.centerLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    e.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (e.finalDate != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Until: ${formatDate(e.finalDate)}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            // QR Code Download
                            Container(
                              height: 60,
                              alignment: Alignment.center,
                              child: IconButton(
                                icon: const Icon(Icons.qr_code_2, color: Colors.green),
                                tooltip: 'Download QR Code',
                                onPressed: () async {
                                  // Find which room(s) this exhibit is in
                                  final roomsResult = await widget.exhibitDao.connection.query(
                                    '''
                                    SELECT r.room_id, r.name
                                    FROM Room r
                                    JOIN Room_Exhibit re ON r.room_id = re.room_id
                                    WHERE re.exhibit_id = @exhibitId
                                    ''',
                                    substitutionValues: {'exhibitId': e.exhibit_id},
                                  );

                                  if (roomsResult.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Exhibit "${e.title}" is not assigned to any room yet'),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                    return;
                                  }

                                  // If multiple rooms, let user choose
                                  int? selectedRoomId;
                                  if (roomsResult.length == 1) {
                                    selectedRoomId = roomsResult.first[0] as int;
                                  } else {
                                    // Show dialog to select room
                                    selectedRoomId = await showDialog<int>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        backgroundColor: Colors.grey[900],
                                        title: const Text(
                                          'Select Room',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: roomsResult.map((row) {
                                            final roomId = row[0] as int;
                                            final roomName = row[1] as String;
                                            return ListTile(
                                              title: Text(
                                                roomName,
                                                style: const TextStyle(color: Colors.white),
                                              ),
                                              subtitle: Text(
                                                'Room ID: $roomId',
                                                style: TextStyle(color: Colors.grey[400]),
                                              ),
                                              onTap: () => Navigator.pop(context, roomId),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    );
                                  }

                                  if (selectedRoomId != null) {
                                    final success = await QRCodeHelper.downloadQRCode(
                                      exhibitId: e.exhibit_id,
                                      roomId: selectedRoomId,
                                      exhibitTitle: e.title,
                                    );

                                    if (success && mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('QR code downloaded for "${e.title}"'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                            ),
                            // Edit
                            Container(
                              height: 60,
                              alignment: Alignment.center,
                              child: IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _openEditDialog(e),
                              ),
                            ),
                            // Delete
                            Container(
                              height: 60,
                              alignment: Alignment.center,
                              child: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteExhibit(e),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Stats
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
                            'Total Exhibits',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[400],
                            ),
                          ),
                          Text(
                            exhibits.length.toString(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.museum,
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