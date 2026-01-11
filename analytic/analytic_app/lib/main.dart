import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';

import 'package:analytic_app/ui/pages/analytics_dashboard_page.dart';
import 'package:analytic_app/data/analytics_dao.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final connection = PostgreSQLConnection(
    '10.0.2.2', //for emulation : '10.0.2.2' / for physical device : 'localhost'
    5432,
    'museum_DB',
    username: 'admin',
    password: 'eaeaoh',
  );

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
      /*home: AdminPage(
        adminDao: adminDao,
        exhibitDao: exhibitDao,
        roomDao: roomDao,
        visitorDao: visitorDao,
        analyticsDao: analyticsDao,
        sessionId: sessionId,
      )
      */
      
    );
  }
}