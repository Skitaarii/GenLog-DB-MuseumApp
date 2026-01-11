import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';
import 'package:visitor_app/data/exhibit_dao.dart';
import 'package:visitor_app/data/room_dao.dart';
import 'package:visitor_app/data/visitor_dao.dart';
import 'package:visitor_app/data/itinerary_dao.dart'; 
import 'package:visitor_app/data/favorites_dao.dart';
import 'package:visitor_app/ui/pages/qr_code_scan_page.dart';
import 'package:visitor_app/utils/language_manager.dart';

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

  final exhibitDao = ExhibitDao(connection);
  final roomDao = RoomDao(connection);
  final visitorDao = VisitorDao(connection);
  final itineraryDao = ItineraryDao(connection); 
  final favoritesDao = FavoritesDao(connection);

  //Session for the visitor
  final sessionId = await visitorDao.createNewSession();
  print('New session created: $sessionId');

  runApp(ListenableBuilder(listenable:LanguageManager(), builder: (context, child) => 
    MyApp(
    exhibitDao: exhibitDao,
    roomDao: roomDao,
    visitorDao: visitorDao,
    itineraryDao: itineraryDao,
    favoritesDao: favoritesDao, 
    sessionId: sessionId,
  )));
}

class MyApp extends StatelessWidget {
  final ExhibitDao exhibitDao;
  final RoomDao roomDao;
  final VisitorDao visitorDao;
  final ItineraryDao itineraryDao; 
  final FavoritesDao favoritesDao; 
  final int sessionId;

  const MyApp({
    super.key,
    required this.exhibitDao,
    required this.roomDao,
    required this.visitorDao,
    required this.itineraryDao, 
    required this.favoritesDao, 
    required this.sessionId,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: QRCodeScanPage(
        visitorDao: visitorDao,
        itineraryDao: itineraryDao,
        favoritesDao: favoritesDao, 
        sessionId: sessionId,
      ),
    );
  }
}