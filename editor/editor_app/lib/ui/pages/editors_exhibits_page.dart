// Veuillet Gaëtan
// 2025
// Description : Exhibit page adding/modifying/deleting for admin
// Administration interface for managing museum exhibits (CRUD operations with images)

import 'package:flutter/material.dart';
import 'package:editor_app/data/exhibit_dao.dart';
import 'package:editor_app/data/exhibit.dart';
import 'package:intl/intl.dart';
import 'package:editor_app/utils/qr_code_helper.dart';
import 'package:image_picker/image_picker.dart';  
import 'dart:typed_data';                          
import 'dart:io';      

// Date formatter for consistent date display
final DateFormat _dateFormatter = DateFormat('dd.MM.yyyy');

// Helper function to format dates, returns '-' for null dates
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
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadExhibits();
  }

  // Reload exhibits from database
  void _loadExhibits() {
    _exhibitsFuture = widget.exhibitDao.getAllExhibits();
  }

  // Pick multiple images from device gallery
  Future<List<ExhibitImage>> _pickImages() async {
    final List<XFile> pickedFiles = await _imagePicker.pickMultiImage();
    
    List<ExhibitImage> images = [];
    for (var file in pickedFiles) {
      final bytes = await file.readAsBytes();
      final fileName = file.name.split('.').first;
      
      images.add(ExhibitImage(
        imageData: bytes,
        altText: fileName,
      ));
    }
    
    return images;
  }

  // Open dialog for adding a new exhibit
  Future<void> _openAddExhibitDialog() async {
    final titleController = TextEditingController();
    DateTime? startDate;
    DateTime? finalDate;

    String shortDescText = '';
    String longDescText = '';

    final shortDescController = TextEditingController(text: shortDescText);
    final longDescController = TextEditingController(text: longDescText);

    List<ExhibitImage> selectedImages = [];

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
              return SingleChildScrollView(
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
                    
                    // Input fields
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

                    // Image picker section
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.purple[700]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.image, color: Colors.purple[300]),
                              const SizedBox(width: 8),
                              Text(
                                'Images (${selectedImages.length})',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final images = await _pickImages();
                                  setDialogState(() {
                                    selectedImages.addAll(images);
                                  });
                                },
                                icon: const Icon(Icons.add_photo_alternate, size: 18),
                                label: const Text('Add Images'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple[700],
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          // Display selected images
                          if (selectedImages.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 100,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: selectedImages.length,
                                itemBuilder: (context, index) {
                                  final img = selectedImages[index];
                                  return Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    child: Stack(
                                      children: [
                                        // Image preview
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.memory(
                                            img.imageData,
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        // Delete button
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: GestureDetector(
                                            onTap: () {
                                              setDialogState(() {
                                                selectedImages.removeAt(index);
                                              });
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                              padding: const EdgeInsets.all(4),
                                              child: const Icon(
                                                Icons.close,
                                                size: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),                    

                    // Date selection section
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.purple[700]!),
                      ),
                      child: Column(
                        children: [
                          // Start date picker
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
                          
                          // End date picker
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

                    // Dialog buttons
                    Row(
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
                              // Validate required fields
                              if (titleController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please enter a title'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              // Get or create description IDs
                              final short_desc = await widget.exhibitDao.getOrCreateShortDescId(shortDescController.text);
                              final long_desc = await widget.exhibitDao.getOrCreateLongDescId(longDescController.text);

                              // Insert exhibit record
                              final exhibitId = await widget.exhibitDao.insertExhibit(
                                  title: titleController.text,
                                  startDate: startDate,
                                  finalDate: finalDate,
                                  shortDescId: short_desc,
                                  longDescId: long_desc,
                                );

                              // Insert associated images
                              for (var image in selectedImages) {
                                await widget.exhibitDao.insertImage(
                                  exhibitId: exhibitId,
                                  imageData: image.imageData,
                                  altText: image.altText,
                                );
                              }

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

  // Open dialog for editing an existing exhibit
  Future<void> _openEditDialog(Exhibit exhibit) async {
    final titleController = TextEditingController(text: exhibit.title);
    DateTime? startDate = exhibit.startDate;
    DateTime? finalDate = exhibit.finalDate;

    String shortDescText = '';
    String longDescText = '';

    // Fetch existing descriptions
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

    // Load existing images and prepare for new ones
    List<ExhibitImage> existingImages = await widget.exhibitDao.getExhibitImages(exhibit.exhibit_id);
    List<ExhibitImage> newImages = [];

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
              return SingleChildScrollView(
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
                          // Title field
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
                          
                          // Short description field
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
                          
                          // Long description field
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
                          // Image management section
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.purple[700]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.image, color: Colors.purple[300]),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Images (${existingImages.length + newImages.length})',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Spacer(),
                                    // Add new images button
                                    ElevatedButton.icon(
                                      onPressed: () async {
                                        final images = await _pickImages();
                                        setDialogState(() {
                                          newImages.addAll(images);
                                        });
                                      },
                                      icon: const Icon(Icons.add_photo_alternate, size: 18),
                                      label: const Text('Add'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.purple[700],
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                // Display all images (existing + new)
                                if (existingImages.isNotEmpty || newImages.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    height: 100,
                                    child: ListView(
                                      scrollDirection: Axis.horizontal,
                                      children: [
                                        // Existing images (from database)
                                        ...existingImages.asMap().entries.map((entry) {
                                          final index = entry.key;
                                          final img = entry.value;
                                          return Container(
                                            margin: const EdgeInsets.only(right: 8),
                                            child: Stack(
                                              children: [
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(8),
                                                  child: Image.memory(
                                                    img.imageData,
                                                    width: 100,
                                                    height: 100,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                // Delete button for existing images
                                                Positioned(
                                                  top: 4,
                                                  right: 4,
                                                  child: GestureDetector(
                                                    onTap: () async {
                                                      // Delete from database immediately
                                                      if (img.imageId != null) {
                                                        await widget.exhibitDao.deleteImage(img.imageId!);
                                                      }
                                                      setDialogState(() {
                                                        existingImages.removeAt(index);
                                                      });
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.red,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      padding: const EdgeInsets.all(4),
                                                      child: const Icon(
                                                        Icons.close,
                                                        size: 16,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }),
                                        // New images (not yet saved to database)
                                        ...newImages.asMap().entries.map((entry) {
                                          final index = entry.key;
                                          final img = entry.value;
                                          return Container(
                                            margin: const EdgeInsets.only(right: 8),
                                            child: Stack(
                                              children: [
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(8),
                                                  child: Image.memory(
                                                    img.imageData,
                                                    width: 100,
                                                    height: 100,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                // "NEW" badge
                                                Positioned(
                                                  top: 4,
                                                  left: 4,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.green,
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    padding: const EdgeInsets.all(4),
                                                    child: const Text(
                                                      'NEW',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                // Delete button for new images
                                                Positioned(
                                                  top: 4,
                                                  right: 4,
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      // Just remove from list, not saved yet
                                                      setDialogState(() {
                                                        newImages.removeAt(index);
                                                      });
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.red,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      padding: const EdgeInsets.all(4),
                                                      child: const Icon(
                                                        Icons.close,
                                                        size: 16,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Date selection section
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.purple[700]!),
                            ),
                            child: Column(
                              children: [
                                // Start date picker
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
                                
                                // End date picker
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

                    // Dialog buttons
                    Row(
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
                              // Update exhibit information
                              await widget.exhibitDao.update(
                                exhibitId: exhibit.exhibit_id,
                                title: titleController.text,
                                startDate: startDate,
                                finalDate: finalDate,
                                shortDesc: shortDescController.text,
                                longDesc: longDescController.text,
                              );
                              // Insert new images
                              for (var image in newImages) {
                                await widget.exhibitDao.insertImage(
                                  exhibitId: exhibit.exhibit_id,
                                  imageData: image.imageData,
                                  altText: image.altText,
                                );
                              }

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

  // Confirm and delete an exhibit
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

          final exhibits = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ADD NEW EXHIBIT BUTTON
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

                // EXHIBITS TABLE
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
                      0: FixedColumnWidth(60),  // ID
                      1: FlexColumnWidth(3),    // Title
                      2: FixedColumnWidth(80),  // QR
                      3: FixedColumnWidth(80),  // Edit
                      4: FixedColumnWidth(80),  // Delete
                    },
                    children: [
                      // Table header row
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

                      // Data rows for each exhibit
                      ...exhibits.map((e) {
                        return TableRow(
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                          ),
                          children: [
                            // Exhibit ID
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
                            // Exhibit Title
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
                                  // Display end date if available
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
                            // QR Code Download Button
                            Container(
                              height: 60,
                              alignment: Alignment.center,
                              child: IconButton(
                                icon: const Icon(Icons.qr_code_2, color: Colors.green),
                                tooltip: 'Download QR Code',
                                onPressed: () async {
                                  try {
                                    // Download QR code for this exhibit
                                    final success = await QRCodeHelper.downloadQRCode(
                                      exhibit_id: e.exhibit_id,
                                      exhibitTitle: e.title,
                                    );

                                    if (!success) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Failed to save QR code for "${e.title}"'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  } catch (err) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error generating QR for "${e.title}": $err'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              ),
                            ),

                            // Edit Button
                            Container(
                              height: 60,
                              alignment: Alignment.center,
                              child: IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _openEditDialog(e),
                              ),
                            ),
                            // Delete Button
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

                // STATISTICS CARD
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