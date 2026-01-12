// Veuillet Gaëtan
// 2025
// Editor's home page for accessing exhibit, room, and itinerary management

import 'package:flutter/material.dart';
import 'package:editor_app/ui/pages/editors_rooms_page.dart';
import 'package:editor_app/widgets/editors.dart';
import 'package:editor_app/ui/pages/editors_exhibits_page.dart';
import 'package:editor_app/data/exhibit_dao.dart';
import 'package:editor_app/data/room_dao.dart';
import 'package:editor_app/data/itinerary_dao.dart';
import 'package:editor_app/ui/pages/editors_itinerary_page.dart';

/// Main landing page for editors providing access to all management sections
class EditorsHomePage extends StatelessWidget {
  final ExhibitDao exhibitDao;
  final RoomDao roomDao;
  final ItineraryDao itineraryDao;

  const EditorsHomePage({
    super.key,
    required this.exhibitDao,
    required this.roomDao,
    required this.itineraryDao,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Editors App',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.purple[300]!),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Header section
            const SizedBox(height: 20),
            const Text(
              'Editor Management',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage museum content',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 40),

            // EXHIBITS management button
            Container(
              width: 300,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.purple[800]!,
                    Colors.deepPurple[800]!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
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
              child: EditorButton(
                label: 'Exhibits',
                icon: Icons.museum,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditorsExhibitsPage(
                        exhibitDao: exhibitDao,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // ROOMS management button
            Container(
              width: 300,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue[800]!,
                    Colors.indigo[800]!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.4),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: EditorButton(
                label: 'Rooms',
                icon: Icons.room,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditorsRoomsPage(
                        roomDao: roomDao,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // ITINERARIES management button
            Container(
              width: 300,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green[800]!,
                    Colors.teal[700]!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.4),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: EditorButton(
                label: 'Itineraries',
                icon: Icons.map,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditorsItineraryPage(
                        itineraryDao: itineraryDao,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 40),

            // Information panel
            Container(
              padding: const EdgeInsets.all(16),
              width: 300,
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple[800]!),
              ),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info, color: Colors.purple, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Quick Actions',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add, edit or delete exhibits and rooms from the museum database.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}