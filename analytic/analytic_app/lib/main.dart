import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';

import 'package:analytic_app/ui/pages/analytics_dashboard_page.dart';
import 'package:analytic_app/data/analytics_dao.dart';

// Main entry point of the Flutter application
Future<void> main() async {
  // Required Flutter bindings initialization before any operations
  WidgetsFlutterBinding.ensureInitialized();

  // PostgreSQL database connection configuration
  // Note: IP address varies by environment:
  // - Emulator: '10.0.2.2' (localhost alias for Android emulator)
  // - Physical device: Actual server address needed
  final connection = PostgreSQLConnection(
    'localhost', //for emulation : '10.0.2.2' / for physical device : 'localhost'
    5432,
    'museum_DB',
    username: 'admin',
    password: 'eaeaoh',
  );

  // Establish connection to the database

  await connection.open();

  final analyticsDao = AnalyticsDao(connection);

  //Session for the visitor

  runApp(MyApp(
    analyticsDao: analyticsDao,
  ));
}

class MyApp extends StatelessWidget {
  final AnalyticsDao analyticsDao;


  const MyApp({
    super.key,
    required this.analyticsDao,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //For analytic page :
      home: AnalyticsDashboardPage(
        analyticsDao: analyticsDao,
      ),      
    );
  }
}