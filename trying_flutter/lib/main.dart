import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';
import 'package:trying_flutter/data/admin_dao.dart';
import 'package:trying_flutter/data/exhibit_dao.dart';
import 'package:trying_flutter/data/room_dao.dart';
import 'package:trying_flutter/data/visitor_dao.dart';
import 'package:trying_flutter/data/analytics_dao.dart';
import 'package:trying_flutter/ui/pages/admin_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final connection = PostgreSQLConnection(
    'localhost', //for emulation : '10.0.2.2' / for physical device : 'localhost'
    5432,
    'museum_DB',
    username: 'admin',
    password: 'eaeaoh',
  );

  await connection.open();

  final exhibitDao = ExhibitDao(connection);
  final roomDao = RoomDao(connection);
  final visitorDao = VisitorDao(connection);
  final adminDao = AdminDao(connection);
  final analyticsDao = AnalyticsDao(connection);

  //Session for the visitor
  final sessionId = await visitorDao.createNewSession();
  print('New session created: $sessionId');

  runApp(MyApp(
    exhibitDao: exhibitDao,
    roomDao: roomDao,
    visitorDao: visitorDao,
    adminDao: adminDao,
    analyticsDao: analyticsDao,
    sessionId: sessionId,
  ));
}

class MyApp extends StatelessWidget {
  final ExhibitDao exhibitDao;
  final RoomDao roomDao;
  final VisitorDao visitorDao;
  final AdminDao adminDao;
  final AnalyticsDao analyticsDao;
  final int sessionId;

  const MyApp({
    super.key,
    required this.exhibitDao,
    required this.roomDao,
    required this.visitorDao,
    required this.adminDao,
    required this.analyticsDao,
    required this.sessionId,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //For admin page :
      home: AdminPage(
        adminDao: adminDao,
        exhibitDao: exhibitDao,
        roomDao: roomDao,
        visitorDao: visitorDao,
        analyticsDao: analyticsDao,
        sessionId: sessionId,
      ),
      
      /* For visitor page :
      home: QRCodeScanPage(
        visitorDao: visitorDao,
        sessionId: sessionId,
      ),
      */
      
      /* For editors :
      home: EditorsHomePage(
        exhibitDao: exhibitDao,
        roomDao: roomDao,
      ),
      */
    );
  }
}