import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';
import 'package:trying_flutter/data/exhibit_dao.dart';
import 'package:trying_flutter/data/room_dao.dart';
import 'package:trying_flutter/ui/pages/editors_home_page.dart';
import 'package:trying_flutter/ui/pages/my_home_page.dart';

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

  runApp(MyApp(exhibitDao: exhibitDao, roomDao: roomDao,));
}

class MyApp extends StatelessWidget {
  final ExhibitDao exhibitDao;
  final RoomDao roomDao;
  

  const MyApp({super.key, required this.exhibitDao, required this.roomDao});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: EditorsHomePage(
        exhibitDao: exhibitDao,
        roomDao: roomDao,
      ),
    );
  }
}
