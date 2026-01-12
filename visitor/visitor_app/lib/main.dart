import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';
import 'package:visitor_app/data/exhibit_dao.dart';
import 'package:visitor_app/data/room_dao.dart';
import 'package:visitor_app/data/visitor_dao.dart';
import 'package:visitor_app/data/itinerary_dao.dart'; 
import 'package:visitor_app/data/favorites_dao.dart';
import 'package:visitor_app/ui/pages/qr_code_scan_page.dart';
import 'package:visitor_app/utils/language_manager.dart';

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
    5432, // Default PostgreSQL port
    'museum_DB', // Database name
    username: 'admin', // Database user
    password: 'eaeaoh', // Database password
  );

  // Establish connection to the database
  await connection.open();

  // Initialize Data Access Objects (DAOs) for different entities
  final exhibitDao = ExhibitDao(connection);
  final roomDao = RoomDao(connection);
  final visitorDao = VisitorDao(connection);
  final itineraryDao = ItineraryDao(connection); 
  final favoritesDao = FavoritesDao(connection);

  // Create a new visitor session for tracking
  final sessionId = await visitorDao.createNewSession();
  print('New session created: $sessionId');

  // Build and run the application
  // ListenableBuilder ensures UI rebuilds when language changes
  runApp(ListenableBuilder(
    listenable: LanguageManager(), 
    builder: (context, child) => MyApp(
      exhibitDao: exhibitDao,
      roomDao: roomDao,
      visitorDao: visitorDao,
      itineraryDao: itineraryDao,
      favoritesDao: favoritesDao, 
      sessionId: sessionId, // Pass the created session ID to the app
    )
  ));
}

// Root widget of the application
class MyApp extends StatelessWidget {
  // Data Access Objects for database operations
  final ExhibitDao exhibitDao;
  final RoomDao roomDao;
  final VisitorDao visitorDao;
  final ItineraryDao itineraryDao; 
  final FavoritesDao favoritesDao; 
  
  // Unique identifier for the current visitor session
  final int sessionId;

  // Constructor with dependency injection for all DAOs
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
    // MaterialApp as the root widget with QRCodeScanPage as the initial screen
    return MaterialApp(
      home: QRCodeScanPage(
        visitorDao: visitorDao,        // For visitor-related operations
        itineraryDao: itineraryDao,    // For itinerary management
        favoritesDao: favoritesDao,    // For favorites functionality
        sessionId: sessionId,          // Current session identifier
      ),
    );
  }
}