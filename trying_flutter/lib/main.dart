import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';
import 'package:trying_flutter/data/exhibit_dao.dart';
import 'package:trying_flutter/ui/pages/my_home_page.dart';

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

  runApp(MyApp(exhibitDao: exhibitDao));
}

class MyApp extends StatelessWidget {
  final ExhibitDao exhibitDao;

  const MyApp({super.key, required this.exhibitDao});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(
        title: 'Flutter Demo Home Page',
        exhibitDao: exhibitDao,
      ),
    );
  }
}
