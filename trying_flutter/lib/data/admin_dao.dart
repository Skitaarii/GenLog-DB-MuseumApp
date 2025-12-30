// Veuillet Gaëtan
//2025
//Description : data access object for admin pannel. 

import 'package:postgres/postgres.dart';

class AdminDao {
  final PostgreSQLConnection connection;

  AdminDao(this.connection);

  //Function to reset the DB 
  Future<bool> resetDatabase() async {
    try {
      //I saw that it need to deactivate the foreign key constraint, soooo
      await connection.execute('SET session_replication_role = replica;');

      //Delete all the table 
      final dropQueries = [
        'DROP TABLE IF EXISTS Itinerary_Exhibit CASCADE;',
        'DROP TABLE IF EXISTS Itineraries CASCADE;',
        'DROP TABLE IF EXISTS Related_exhibits CASCADE;',
        'DROP TABLE IF EXISTS Feedback CASCADE;',
        'DROP TABLE IF EXISTS QR_Scan CASCADE;',
        'DROP TABLE IF EXISTS Session CASCADE;',
        'DROP TABLE IF EXISTS TagTheme CASCADE;',
        'DROP TABLE IF EXISTS TagEra CASCADE;',
        'DROP TABLE IF EXISTS Themes CASCADE;',
        'DROP TABLE IF EXISTS Eras CASCADE;',
        'DROP TABLE IF EXISTS Tags CASCADE;',
        'DROP TABLE IF EXISTS Images CASCADE;',
        'DROP TABLE IF EXISTS QR_Code CASCADE;',
        'DROP TABLE IF EXISTS Room_Exhibit CASCADE;',
        'DROP TABLE IF EXISTS Room_Connection CASCADE;',
        'DROP TABLE IF EXISTS Room CASCADE;',
        'DROP TABLE IF EXISTS Exhibits CASCADE;',
        'DROP TABLE IF EXISTS Long_Desc CASCADE;',
        'DROP TABLE IF EXISTS Short_Desc CASCADE;',
      ];

      for (final query in dropQueries) {
        await connection.execute(query);
      }

      //ANNNN THEN WE REACTIVATE THNE CONSTRAINT
      await connection.execute('SET session_replication_role = DEFAULT;');

      print('Database reset successfully');
      return true;
    } catch (e) {
      print('Error resetting database: $e');
      return false;
    }
  }

  //Empty table (only for structure)
  Future<bool> createDatabaseStructure() async {
    try {
      final createQueries = [
        ///Short_Desc
        '''
        CREATE TABLE IF NOT EXISTS Short_Desc (
          id SERIAL,
          FR VARCHAR(100),
          EN VARCHAR(100),
          IT VARCHAR(100),
          DE VARCHAR(100),
          PRIMARY KEY (id)
        );
        ''',
        ///Long_Desc
        '''
        CREATE TABLE IF NOT EXISTS Long_Desc (
          id SERIAL,
          FR VARCHAR(300),
          EN VARCHAR(300),
          IT VARCHAR(300),
          DE VARCHAR(300),
          PRIMARY KEY (id)
        );
        ''',
        ///Exhibits
        '''
        CREATE TABLE IF NOT EXISTS Exhibits (
          exhibit_id SERIAL,
          title VARCHAR(50),
          short_desc_id INT,
          long_desc_id INT,
          start_date DATE,
          final_date DATE,
          PRIMARY KEY (exhibit_id),
          FOREIGN KEY (short_desc_id) REFERENCES Short_Desc(id),
          FOREIGN KEY (long_desc_id) REFERENCES Long_Desc(id)
        );
        ''',
        ///Room
        '''
        CREATE TABLE IF NOT EXISTS Room (
          room_id SERIAL,
          name VARCHAR(100),
          PRIMARY KEY (room_id)
        );
        ''',
        ///Room_Connection
        '''
        CREATE TABLE IF NOT EXISTS Room_Connection (
          id SERIAL,
          room1_id INT,
          room2_id INT,
          FOREIGN KEY (room1_id) REFERENCES Room(room_id),
          FOREIGN KEY (room2_id) REFERENCES Room(room_id),
          PRIMARY KEY (id)
        );
        ''',
        ///Room_Exhibit
        '''
        CREATE TABLE IF NOT EXISTS Room_Exhibit (
          id SERIAL,
          room_id INT,
          exhibit_id INT,
          FOREIGN KEY (room_id) REFERENCES Room(room_id),
          FOREIGN KEY (exhibit_id) REFERENCES Exhibits(exhibit_id), 
          PRIMARY KEY (id)
        );
        ''',
        ///QR_Code
        '''
        CREATE TABLE IF NOT EXISTS QR_Code (
          QR_id SERIAL,
          exhibit_id INT,
          room_id INT,
          QR_img_path  TEXT,
          PRIMARY KEY (QR_id),
          FOREIGN KEY (exhibit_id) REFERENCES Exhibits(exhibit_id),
          FOREIGN KEY (room_id) REFERENCES Room(room_id)
        );
        ''',
        ///Images
        '''
        CREATE TABLE IF NOT EXISTS Images (
          image_id SERIAL,
          exhibit_id INT,
          alt_text VARCHAR(100),
          img_path TEXT,
          PRIMARY KEY (image_id),
          FOREIGN KEY (exhibit_id) REFERENCES Exhibits(exhibit_id)
        );
        ''',
        ///Tags
        '''
        CREATE TABLE IF NOT EXISTS Tags (
          tag_id SERIAL,
          exhibit_id INT,
          PRIMARY KEY (tag_id),
          FOREIGN KEY (exhibit_id) REFERENCES Exhibits(exhibit_id)
        );
        ''',
        ///Eras
        '''
        CREATE TABLE IF NOT EXISTS Eras (
          era_id SERIAL,
          era_name_FR VARCHAR(100),
          era_name_EN VARCHAR(100),
          era_name_DE VARCHAR(100),
          era_name_IT VARCHAR(100),
          PRIMARY KEY (era_id)
        );
        ''',
        ///Themes
        '''
        CREATE TABLE IF NOT EXISTS Themes (
          theme_id SERIAL,
          thm_name_FR VARCHAR(100),
          thm_name_EN VARCHAR(100),
          thm_name_DE VARCHAR(100),
          thm_name_IT VARCHAR(100),
          PRIMARY KEY (theme_id)
        );
        ''',
        ///TagEra
        '''
        CREATE TABLE IF NOT EXISTS TagEra (
          id SERIAL,
          tag_id INT,
          era_id INT,
          FOREIGN KEY (tag_id) REFERENCES Tags(tag_id),
          FOREIGN KEY (era_id) REFERENCES Eras(era_id),
          PRIMARY KEY(id)
        );
        ''',
        ///TagTheme
        '''
        CREATE TABLE IF NOT EXISTS TagTheme (
          id SERIAL,
          tag_id INT,
          theme_id INT,
          FOREIGN KEY (tag_id) REFERENCES Tags(tag_id),
          FOREIGN KEY (theme_id) REFERENCES Themes(theme_id),
          PRIMARY KEY(id)
        );
        ''',
        //Session
        '''
        CREATE TABLE IF NOT EXISTS Session (
          session_id SERIAL,
          PRIMARY KEY (session_id)
        );
        ''',
        ///QR_Scan
        '''
        CREATE TABLE IF NOT EXISTS QR_Scan (
          id SERIAL,
          session_id INT,
          room_id INT,
          exhibit_id INT,
          scanned_at TIMESTAMP,
          FOREIGN KEY (session_id) REFERENCES Session(session_id),
          FOREIGN KEY (room_id) REFERENCES Room(room_id),
          FOREIGN KEY (exhibit_id) REFERENCES Exhibits(exhibit_id),
          PRIMARY KEY(id)
        );
        ''',
        ///Feedback
        '''
        CREATE TABLE IF NOT EXISTS Feedback (
          feedback_id SERIAL,
          exhibit_id INT,
          session_id INT,
          comment VARCHAR(200),
          rating INT,
          made_at TIMESTAMP,
          PRIMARY KEY (feedback_id),
          FOREIGN KEY (exhibit_id) REFERENCES Exhibits(exhibit_id),
          FOREIGN KEY (session_id) REFERENCES Session(session_id)
        );
        ''',
        ///Related_exhibits
        '''
        CREATE TABLE IF NOT EXISTS Related_exhibits (
          relation_id SERIAL,
          exhibit1_id INT,
          exhibit2_id INT,
          PRIMARY KEY (relation_id),
          FOREIGN KEY (exhibit1_id) REFERENCES Exhibits(exhibit_id),
          FOREIGN KEY (exhibit2_id) REFERENCES Exhibits(exhibit_id)
        );
        ''',
        //Itineraries
        '''
        CREATE TABLE IF NOT EXISTS Itineraries (
          itinerary_id SERIAL,
          title VARCHAR(50),
          PRIMARY KEY (itinerary_id)
        );
        ''',
        ///Itinerary_Exhibit
        '''
        CREATE TABLE IF NOT EXISTS Itinerary_Exhibit (
          id SERIAL,
          exhibit_id INT,
          itinerary_id INT,
          FOREIGN KEY (exhibit_id) REFERENCES Exhibits(exhibit_id),
          FOREIGN KEY (itinerary_id) REFERENCES Itineraries(itinerary_id),
          PRIMARY KEY (id)
        );
        ''',
      ];

      for (final query in createQueries) {
        await connection.execute(query);
      }

      print('Database structure created successfully');
      return true;
    } catch (e) {
      print('Error creating database structure: $e');
      return false;
    }
  }

  //Function to populate the table with some placeholder (or not)
  //TODO : DEFINE WHICH DATA WE WANT SO WE DONT HAVE TO REWRITE THEM EVERYTIME
  //Basically, the way it works is that 
  //1) we create the structure (if not already done);
  //2)For exhibits descriptions, I create arrays to store them then insert them;
  //3)Insert exhibits;
  //4)Insert rooms;
  //5)associate exhibit per room;
  //6)Insert era;
  //7)Insert themes;
  //8)Insert tags and associate them;
  //9)Create session;
  //10)Create feedback -> to test scoring and so on;
  //11)Insert Qrcode, not really usefull but eh.

  //These data are generated by chatgpt, may not be real but it's just to have placeholder
  Future<bool> populateWithSampleData() async {
    try {
      await createDatabaseStructure();

      final shortDescIds = <int>[];
      final longDescIds = <int>[];
      
      final shortDescriptions = [
        ['La Joconde, chef-d\'œuvre de Léonard de Vinci', 'The Mona Lisa, masterpiece by Leonardo da Vinci', 'La Gioconda, capolavoro di Leonardo da Vinci', 'Die Mona Lisa, Meisterwerk von Leonardo da Vinci'],
        ['Télescope historique de Galilée', 'Historical telescope of Galileo', 'Telescopio storico di Galileo', 'Historisches Teleskop von Galileo'],
        ['Épave antique bien préservée', 'Well-preserved ancient shipwreck', 'Relitto antico ben conservato', 'Gut erhaltenes antikes Schiffswrack'],
        ['Collection de statues romaines', 'Collection of Roman statues', 'Collezione di statue romane', 'Sammlung römischer Statuen'],
        ['Œuvre d\'art abstrait moderne', 'Modern abstract artwork', 'Opera d\'arte astratta moderna', 'Moderne abstrakte Kunstwerk'],
        ['Robot intelligent avec IA', 'Smart robot with AI', 'Robot intelligente con IA', 'Intelligenter Roboter mit KI'],
      ];

      final longDescriptions = [
        [
          'La Joconde, également appelée Mona Lisa, est un tableau de l\'artiste Léonard de Vinci, réalisé entre 1503 et 1506. Cette œuvre d\'art est devenue un symbole de la Renaissance italienne.',
          'The Mona Lisa, also known as La Gioconda, is a painting by the artist Leonardo da Vinci, created between 1503 and 1506. This artwork has become a symbol of the Italian Renaissance.',
          'La Gioconda, nota anche come Monna Lisa, è un dipinto dell\'artista Leonardo da Vinci, realizzato tra il 1503 e il 1506. Quest\'opera d\'arte è diventata un simbolo del Rinascimento italiano.',
          'Die Mona Lisa, auch bekannt als La Gioconda, ist ein Gemälde des Künstlers Leonardo da Vinci, das zwischen 1503 und 1506 entstanden ist. Dieses Kunstwerk ist zu einem Symbol der italienischen Renaissance geworden.'
        ],
        [
          'Ce télescope historique a été utilisé par Galilée pour ses observations révolutionnaires du ciel nocturne. Il a découvert les lunes de Jupiter et les phases de Vénus.',
          'This historical telescope was used by Galileo for his revolutionary observations of the night sky. He discovered Jupiter\'s moons and the phases of Venus.',
          'Questo telescopio storico è stato utilizzato da Galileo per le sue osservazioni rivoluzionarie del cielo notturno. Ha scoperto le lune di Giove e le fasi di Venere.',
          'Dieses historische Teleskop wurde von Galileo für seine revolutionären Beobachtungen des Nachthimmels verwendet. Er entdeckte die Monde des Jupiter und die Phasen der Venus.'
        ],
        [
          'Découverte en 1985, cette épave romaine datant du 1er siècle apr. J.-C. contient des amphores, des artefacts et offre un aperçu unique du commerce maritime antique.',
          'Discovered in 1985, this Roman shipwreck dating from the 1st century AD contains amphorae, artifacts and provides unique insight into ancient maritime trade.',
          'Scoperto nel 1985, questo relitto romano risalente al I secolo d.C. contiene anfore, manufatti e offre uno spaccato unico del commercio marittimo antico.',
          'Entdeckt im Jahr 1985, enthält dieses römische Schiffswrack aus dem 1. Jahrhundert n. Chr. Amphoren, Artefakte und bietet einen einzigartigen Einblick in den antiken Seehandel.'
        ],
        [
          'Cette collection présente des statues romaines du 2ème siècle, représentant des dieux, des empereurs et des citoyens, montrant l\'expertise artistique de l\'Empire romain.',
          'This collection features Roman statues from the 2nd century, depicting gods, emperors and citizens, showing the artistic expertise of the Roman Empire.',
          'Questa collezione presenta statue romane del II secolo, che raffigurano dei, imperatori e cittadini, mostrando l\'esperienza artistica dell\'Impero Romano.',
          'Diese Sammlung zeigt römische Statuen aus dem 2. Jahrhundert, die Götter, Kaiser und Bürger darstellen und die künstlerische Expertise des Römischen Reiches zeigen.'
        ],
        [
          'Cette peinture abstraite moderne explore les couleurs et les formes. L\'artiste utilise des techniques innovantes pour exprimer des émotions complexes.',
          'This modern abstract painting explores colors and shapes. The artist uses innovative techniques to express complex emotions.',
          'Questo dipinto astratto moderno esplora colori e forme. L\'artista utilizza tecniche innovative per esprimere emozioni complesse.',
          'Dieses moderne abstrakte Gemälde erforscht Farben und Formen. Der Künstler verwendet innovative Techniken, um komplexe Emotionen auszudrücken.'
        ],
        [
          'Ce robot équipé d\'intelligence artificielle peut interagir avec les visiteurs, répondre aux questions et démontrer les avancées technologiques actuelles.',
          'This robot equipped with artificial intelligence can interact with visitors, answer questions and demonstrate current technological advances.',
          'Questo robot dotato di intelligenza artificiale può interagire con i visitatori, rispondere alle domande e dimostrare i progressi tecnologici attuali.',
          'Dieser mit künstlicher Intelligenz ausgestattete Roboter kann mit Besuchern interagieren, Fragen beantworten und aktuelle technologische Fortschritte demonstrieren.'
        ],
      ];

      for (int i = 0; i < shortDescriptions.length; i++) {
        final shortResult = await connection.query(
          'INSERT INTO Short_Desc (FR, EN, IT, DE) VALUES (@fr, @en, @it, @de) RETURNING id',
          substitutionValues: {
            'fr': shortDescriptions[i][0],
            'en': shortDescriptions[i][1],
            'it': shortDescriptions[i][2],
            'de': shortDescriptions[i][3],
          },
        );
        shortDescIds.add(shortResult.first[0] as int);

        final longResult = await connection.query(
          'INSERT INTO Long_Desc (FR, EN, IT, DE) VALUES (@fr, @en, @it, @de) RETURNING id',
          substitutionValues: {
            'fr': longDescriptions[i][0],
            'en': longDescriptions[i][1],
            'it': longDescriptions[i][2],
            'de': longDescriptions[i][3],
          },
        );
        longDescIds.add(longResult.first[0] as int);
      }

      final exhibitIds = <int>[];
      final exhibits = [
        {
          'title': 'Mona Lisa',
          'short_desc_id': shortDescIds[0],
          'long_desc_id': longDescIds[0],
          'start_date': DateTime(2024, 1, 1),
          'final_date': DateTime(2024, 12, 31),
        },
        {
          'title': 'Galileo\'s Telescope',
          'short_desc_id': shortDescIds[1],
          'long_desc_id': longDescIds[1],
          'start_date': DateTime(2024, 2, 1),
          'final_date': DateTime(2024, 11, 30),
        },
        {
          'title': 'Roman Shipwreck',
          'short_desc_id': shortDescIds[2],
          'long_desc_id': longDescIds[2],
          'start_date': DateTime(2024, 3, 1),
          'final_date': DateTime(2024, 10, 31),
        },
        {
          'title': 'Roman Statues Collection',
          'short_desc_id': shortDescIds[3],
          'long_desc_id': longDescIds[3],
          'start_date': DateTime(2024, 4, 1),
          'final_date': DateTime(2024, 9, 30),
        },
        {
          'title': 'Abstract Harmony',
          'short_desc_id': shortDescIds[4],
          'long_desc_id': longDescIds[4],
          'start_date': DateTime(2024, 5, 1),
          'final_date': DateTime(2024, 8, 31),
        },
        {
          'title': 'AI Companion Robot',
          'short_desc_id': shortDescIds[5],
          'long_desc_id': longDescIds[5],
          'start_date': DateTime(2024, 6, 1),
          'final_date': DateTime(2024, 7, 31),
        },
      ];

      for (final exhibit in exhibits) {
        final result = await connection.query(
          '''
          INSERT INTO Exhibits (title, short_desc_id, long_desc_id, start_date, final_date)
          VALUES (@title, @short_desc_id, @long_desc_id, @start_date, @final_date)
          RETURNING exhibit_id
          ''',
          substitutionValues: exhibit,
        );
        exhibitIds.add(result.first[0] as int);
      }

      final roomIds = <int>[];
      final rooms = [
        'Main Hall',
        'Science Wing',
        'Maritime Gallery',
        'Ancient World',
        'Modern Art Room',
      ];

      for (final room in rooms) {
        final result = await connection.query(
          'INSERT INTO Room (name) VALUES (@name) RETURNING room_id',
          substitutionValues: {'name': room},
        );
        roomIds.add(result.first[0] as int);
      }

      //5)
      final roomExhibits = [
        {'room_id': roomIds[0], 'exhibit_id': exhibitIds[0]}, // Mona Lisa -> Main Hall
        {'room_id': roomIds[0], 'exhibit_id': exhibitIds[3]}, // Roman Statues -> Main Hall
        {'room_id': roomIds[1], 'exhibit_id': exhibitIds[1]}, // Telescope -> Science Wing
        {'room_id': roomIds[1], 'exhibit_id': exhibitIds[5]}, // Robot -> Science Wing
        {'room_id': roomIds[2], 'exhibit_id': exhibitIds[2]}, // Shipwreck -> Maritime Gallery
        {'room_id': roomIds[3], 'exhibit_id': exhibitIds[3]}, // Roman Statues -> Ancient World
        {'room_id': roomIds[4], 'exhibit_id': exhibitIds[4]}, // Abstract Art -> Modern Art Room
      ];

      for (final re in roomExhibits) {
        await connection.execute(
          'INSERT INTO Room_Exhibit (room_id, exhibit_id) VALUES (@room_id, @exhibit_id)',
          substitutionValues: re,
        );
      }

      //6)
      final eraIds = <int>[];
      final eras = [
        ['Renaissance', 'Renaissance', 'Rinascimento', 'Renaissance'],
        ['Âge Moderne', 'Modern Age', 'Età moderna', 'Moderne Zeit'],
        ['Antiquité', 'Antiquity', 'Antichità', 'Altertum'],
        ['Époque Contemporaine', 'Contemporary Era', 'Epoca contemporanea', 'Zeitgenössische Ära'],
        ['Futur Proche', 'Near Future', 'Futuro prossimo', 'Nahe Zukunft'],
      ];

      for (final era in eras) {
        final result = await connection.query(
          '''
          INSERT INTO Eras (era_name_FR, era_name_EN, era_name_IT, era_name_DE)
          VALUES (@fr, @en, @it, @de) RETURNING era_id
          ''',
          substitutionValues: {
            'fr': era[0],
            'en': era[1],
            'it': era[2],
            'de': era[3],
          },
        );
        eraIds.add(result.first[0] as int);
      }

      //7)
      final themeIds = <int>[];
      final themes = [
        ['Art', 'Art', 'Arte', 'Kunst'],
        ['Science', 'Science', 'Scienza', 'Wissenschaft'],
        ['Histoire', 'History', 'Storia', 'Geschichte'],
        ['Technologie', 'Technology', 'Tecnologia', 'Technologie'],
        ['Archéologie', 'Archaeology', 'Archeologia', 'Archäologie'],
      ];

      for (final theme in themes) {
        final result = await connection.query(
          '''
          INSERT INTO Themes (thm_name_FR, thm_name_EN, thm_name_IT, thm_name_DE)
          VALUES (@fr, @en, @it, @de) RETURNING theme_id
          ''',
          substitutionValues: {
            'fr': theme[0],
            'en': theme[1],
            'it': theme[2],
            'de': theme[3],
          },
        );
        themeIds.add(result.first[0] as int);
      }

      //8)
      for (int i = 0; i < exhibitIds.length; i++) {
        //Create a tag for each exhibit
        final tagResult = await connection.query(
          'INSERT INTO Tags (exhibit_id) VALUES (@exhibit_id) RETURNING tag_id',
          substitutionValues: {'exhibit_id': exhibitIds[i]},
        );
        final tagId = tagResult.first[0] as int;

        //Logic distribution to an era
        int eraIndex;
        if (i == 0) eraIndex = 0; // Mona Lisa -> Renaissance
        else if (i == 1) eraIndex = 1; // Telescope -> Modern Age
        else if (i == 2 || i == 3) eraIndex = 2; // Roman items -> Antiquity
        else if (i == 4) eraIndex = 3; // Abstract Art -> Contemporary
        else eraIndex = 4; // Robot -> Near Future
        
        await connection.execute(
          'INSERT INTO TagEra (tag_id, era_id) VALUES (@tag_id, @era_id)',
          substitutionValues: {'tag_id': tagId, 'era_id': eraIds[eraIndex]},
        );

        //Associate to theme
        List<int> exhibitThemes = [];
        switch (i) {
          case 0: // Mona Lisa
            exhibitThemes = [0, 1]; // Art, Science 
            break;
          case 1: // Telescope
            exhibitThemes = [1, 2]; // Science, History
            break;
          case 2: // Shipwreck
            exhibitThemes = [2, 4]; // History, Archaeology
            break;
          case 3: // Roman Statues
            exhibitThemes = [0, 2, 4]; // Art, History, Archaeology
            break;
          case 4: // Abstract Art
            exhibitThemes = [0]; // Art
            break;
          case 5: // Robot
            exhibitThemes = [1, 3]; // Science, Technology
            break;
        }

        for (final themeIndex in exhibitThemes) {
          await connection.execute(
            'INSERT INTO TagTheme (tag_id, theme_id) VALUES (@tag_id, @theme_id)',
            substitutionValues: {'tag_id': tagId, 'theme_id': themeIds[themeIndex]},
          );
        }
      }

      //9)
      final sessionResult = await connection.query(
        'INSERT INTO Session DEFAULT VALUES RETURNING session_id'
      );
      final sampleSessionId = sessionResult.first[0] as int;

      //10)
      final feedbacks = [
        {
          'exhibit_id': exhibitIds[0],
          'session_id': sampleSessionId,
          'comment': 'Absolutely breathtaking! The details are incredible.',
          'rating': 5,
          'made_at': DateTime.now().subtract(const Duration(days: 10)),
        },
        {
          'exhibit_id': exhibitIds[0],
          'session_id': sampleSessionId,
          'comment': 'Smaller than expected but still impressive.',
          'rating': 4,
          'made_at': DateTime.now().subtract(const Duration(days: 8)),
        },
        {
          'exhibit_id': exhibitIds[1],
          'session_id': sampleSessionId,
          'comment': 'Fascinating piece of scientific history.',
          'rating': 5,
          'made_at': DateTime.now().subtract(const Duration(days: 5)),
        },
        {
          'exhibit_id': exhibitIds[2],
          'session_id': sampleSessionId,
          'comment': 'Well-preserved artifacts from ancient times.',
          'rating': 4,
          'made_at': DateTime.now().subtract(const Duration(days: 3)),
        },
        {
          'exhibit_id': exhibitIds[5],
          'session_id': sampleSessionId,
          'comment': 'The robot interaction was amazing!',
          'rating': 5,
          'made_at': DateTime.now().subtract(const Duration(days: 1)),
        },
      ];

      for (final feedback in feedbacks) {
        await connection.execute(
          '''
          INSERT INTO Feedback (exhibit_id, session_id, comment, rating, made_at)
          VALUES (@exhibit_id, @session_id, @comment, @rating, @made_at)
          ''',
          substitutionValues: feedback,
        );
      }

      //11)
      for (int i = 0; i < 3; i++) {
        await connection.execute(
          '''
          INSERT INTO QR_Scan (session_id, room_id, exhibit_id, scanned_at)
          VALUES (@session_id, @room_id, @exhibit_id, @scanned_at)
          ''',
          substitutionValues: {
            'session_id': sampleSessionId,
            'room_id': roomIds[i % roomIds.length],
            'exhibit_id': exhibitIds[i],
            'scanned_at': DateTime.now().subtract(Duration(hours: i * 2)),
          },
        );
      }
      
      return true;
    } catch (e) {
      print('Error populating sample data: $e');
      rethrow; //pour mieux déboguer
    }
  }

  Future<bool> isDatabaseEmpty() async {
    try {
      final result = await connection.query(
        "SELECT COUNT(*) as count FROM information_schema.tables WHERE table_schema = 'public'"
      );
      final tableCount = result.first[0] as int;
      return tableCount == 0;
    } catch (e) {
      print('Error checking database: $e');
      return true;
    }
  }

  Future<bool> hasSampleData() async {
    try {
      final result = await connection.query(
        'SELECT COUNT(*) as count FROM Exhibits'
      );
      final exhibitCount = result.first[0] as int;
      return exhibitCount > 0;
    } catch (e) {
      print('Error checking sample data: $e');
      return false;
    }
  }
}