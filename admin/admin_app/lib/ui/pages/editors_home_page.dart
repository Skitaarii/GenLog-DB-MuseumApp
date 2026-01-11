// Veuillet Gaëtan
// 2025
// Description : Editors home page to have access to editing Exhbits/Rooms/Itineraries

import 'package:flutter/material.dart';
import 'package:admin_app/ui/pages/editors_rooms_page.dart';
import 'package:admin_app/widgets/editors.dart';
import 'package:admin_app/ui/pages/editors_exhibits_page.dart';
import 'package:admin_app/data/exhibit_dao.dart';
import 'package:admin_app/data/room_dao.dart';

class EditorsHomePage extends StatelessWidget {
  final ExhibitDao exhibitDao;
  final RoomDao roomDao;

  const EditorsHomePage({
    super.key,
    required this.exhibitDao,
    required this.roomDao,
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
            child: TextButton(
              onPressed: () {
                // plus tard : switch EN / FR / IT / DE
              },
              child: const Text(
                'EN / FR',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title
            /*const Icon(
              Icons.admin_panel_settings,
              size: 80,
              color: Colors.purple,
            ),
            */
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

            //Actions button
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
                  // Navigator.push(...)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Itineraries section coming soon!'),
                      backgroundColor: Colors.purple[700],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 40),

            // Informations
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