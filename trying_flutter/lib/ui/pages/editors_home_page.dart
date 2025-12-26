import 'package:flutter/material.dart';
import 'package:trying_flutter/widgets/editors.dart';
import 'package:trying_flutter/ui/pages/editors_exhibits_page.dart';
import 'package:trying_flutter/data/exhibit_dao.dart';

class EditorsHomePage extends StatelessWidget {
  final ExhibitDao exhibitDao;
  const EditorsHomePage({
    super.key,
    required this.exhibitDao,
    });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editors'),
        actions: [
          TextButton(
            onPressed: () {
              // plus tard : switch EN / FR
            },
            child: const Text(
              'EN / FR',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            EditorButton(
              label: 'Exhibits',
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
            const SizedBox(height: 20),
            EditorButton(
              label: 'Rooms',
              onTap: () {
                // Navigator.push(...)
              },
            ),
            const SizedBox(height: 20),
            EditorButton(
              label: 'Itineraries',
              onTap: () {
                // Navigator.push(...)
              },
            ),
          ],
        ),
      ),
    );
  }
}
