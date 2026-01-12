
import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';
import 'package:admin_app/data/admin_dao.dart';

import 'package:admin_app/data/visitor_dao.dart';
import 'package:admin_app/ui/pages/admin_page.dart';

// Main entry point of the Flutter application
Future<void> main() async {
  // Required Flutter bindings initialization before any operations
  WidgetsFlutterBinding.ensureInitialized();


  // PostgreSQL database connection configuration
  // Note: IP address varies by environment:
  // - Emulator: '10.0.2.2' (localhost alias for Android emulator)
  // - Physical device: Actual server address needed
  final connection = PostgreSQLConnection(
    '10.0.2.2', //for emulation : '10.0.2.2' / for physical device : 'localhost'
    5432,
    'museum_DB',
    username: 'admin',
    password: 'eaeaoh',
  );

  // Establish connection to the database
  await connection.open();

  final visitorDao = VisitorDao(connection);
  final adminDao = AdminDao(connection); 

  //Session for the visitor
  final sessionId = await visitorDao.createNewSession();
  print('New session created: $sessionId');

  runApp(MyApp(
    adminDao: adminDao,
    sessionId: sessionId,
  ));
}

class MyApp extends StatelessWidget {
  final AdminDao adminDao; 
  final int sessionId;

  const MyApp({
    super.key,
    required this.adminDao, 
    required this.sessionId,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //For admin page :
      home: AdminPage(
        adminDao: adminDao,
        sessionId: sessionId,
      ),
      
    );
  }
}