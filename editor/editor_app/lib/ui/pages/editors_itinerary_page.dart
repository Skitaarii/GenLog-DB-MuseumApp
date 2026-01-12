// Veuillet Gaëtan
// 2025
// Itinerary management page for editors - add, modify, delete itineraries

import 'package:flutter/material.dart';
import 'package:editor_app/data/itinerary_dao.dart';
import 'package:editor_app/data/itinerary.dart';

class EditorsItineraryPage extends StatefulWidget {
  final ItineraryDao itineraryDao;

  const EditorsItineraryPage({
    super.key,
    required this.itineraryDao,
  });

  @override
  State<EditorsItineraryPage> createState() => _EditorsItineraryPageState();
}

class _EditorsItineraryPageState extends State<EditorsItineraryPage> {
  late Future<List<ItineraryWithExhibits>> _itinerariesFuture;

  @override
  void initState() {
    super.initState();
    _loadItineraries();
  }

  void _loadItineraries() {
    _itinerariesFuture = widget.itineraryDao.getItinerariesWithExhibits();
  }

  /// Opens dialog to create a new itinerary with title and exhibit selection
  Future<void> _openAddItineraryDialog() async {
    final titleController = TextEditingController();

    // Fetch all available exhibits for selection
    final availableExhibits = await widget.itineraryDao.getAllExhibits();
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
                // Dialog header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'New Itinerary',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Divider(color: Colors.purple[700]),
                // Dialog content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title input
                        TextField(
                          controller: titleController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Itinerary Title',
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
                        // Exhibit selection header
                        Text(
                          'Select exhibits for this itinerary:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Exhibit list (empty state)
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
                        // Exhibit list (with checkboxes)
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
                // Dialog buttons
                Divider(color: Colors.purple[700]),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Cancel button
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
                      // Create button
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
                                  content: Text('Please enter an itinerary title'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            // Create itinerary and associate exhibits
                            final newItineraryId = await widget.itineraryDao.createItinerary(
                              title: titleController.text,
                            );
                            
                            if (selected.isNotEmpty) {
                              await widget.itineraryDao.updateItineraryExhibits(
                                newItineraryId,
                                selected.toList(),
                              );
                            }

                            Navigator.pop(context);
                            setState(() {
                              _loadItineraries();
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

  /// Opens dialog to edit an existing itinerary
  Future<void> _openEditDialog(ItineraryWithExhibits itinerary) async {
    final titleController = TextEditingController(text: itinerary.title);
    
    // Fetch all exhibits and pre-select current ones
    final availableExhibits = await widget.itineraryDao.getAllExhibits();
    final selected = <int>{...itinerary.exhibits.map((e) => e.exhibit_id)};

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
                // Dialog header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Edit Itinerary',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Divider(color: Colors.purple[700]),
                // Dialog content (same structure as add dialog)
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: titleController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Itinerary Title',
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
                          'Select exhibits for this itinerary:',
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
                // Dialog buttons
                Divider(color: Colors.purple[700]),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Cancel button
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
                      // Save button
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
                                  content: Text('Please enter an itinerary title'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            // Update itinerary title and exhibits
                            await widget.itineraryDao.updateItinerary(
                              itinerary.itinerary_id,
                              title: titleController.text,
                            );
                            
                            await widget.itineraryDao.updateItineraryExhibits(
                              itinerary.itinerary_id,
                              selected.toList(),
                            );

                            Navigator.pop(context);
                            setState(() {
                              _loadItineraries();
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

  /// Confirms and deletes an itinerary
  Future<void> _deleteItinerary(ItineraryWithExhibits itinerary) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Delete Itinerary', style: TextStyle(color: Colors.white)),
        content: Text(
          'Delete "${itinerary.title}"? This will also remove all exhibit associations.',
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
      await widget.itineraryDao.deleteItinerary(itinerary.itinerary_id);
      setState(() => _loadItineraries());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Itineraries Management',
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
      body: FutureBuilder<List<ItineraryWithExhibits>>(
        future: _itinerariesFuture,
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
              ),
            );
          }

          // Error state
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          final itineraries = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ADD NEW ITINERARY BUTTON
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
                    onPressed: _openAddItineraryDialog,
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      'Add New Itinerary',
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

                // ITINERARIES TABLE
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
                      // TABLE HEADER
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
                              'Itinerary Title',
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
                      // TABLE DATA ROWS
                      ...itineraries.map((itin) {
                        return TableRow(
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                          ),
                          children: [
                            // Title column
                            Container(
                              padding: const EdgeInsets.all(12),
                              alignment: Alignment.centerLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    itin.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'ID: ${itin.itinerary_id}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Exhibits column
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
                                    if (itin.exhibits.isEmpty)
                                      Text(
                                        'No exhibits assigned',
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontStyle: FontStyle.italic,
                                        ),
                                      )
                                    else
                                      ...itin.exhibits.map((ex) => Padding(
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
                            // Edit button column
                            Container(
                              height: 60,
                              alignment: Alignment.center,
                              child: IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _openEditDialog(itin),
                              ),
                            ),
                            // Delete button column
                            Container(
                              height: 60,
                              alignment: Alignment.center,
                              child: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteItinerary(itin),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // STATISTICS PANEL
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
                            'Total Itineraries',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[400],
                            ),
                          ),
                          Text(
                            itineraries.length.toString(),
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
                            itineraries.fold(0, (sum, itin) => sum + itin.exhibits.length).toString(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.map,
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