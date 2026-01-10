// Gaëtan Veuillet
// 2025
// Data Access Object for Itinerary (Visitor - Read Only)

import 'package:postgres/postgres.dart';
import 'package:visitor_app/data/itinerary.dart';
import 'package:visitor_app/data/exhibit.dart';

class ItineraryDao {
  final PostgreSQLConnection connection;

  ItineraryDao(this.connection);

  // Get all itineraries (basic info only)
  Future<List<Itinerary>> getAllItineraries() async {
    try {
      final result = await connection.query(
        'SELECT itinerary_id, title FROM Itineraries ORDER BY itinerary_id',
      );

      return result.map((row) {
        return Itinerary(
          itinerary_id: row[0] as int,
          title: row[1] as String,
        );
      }).toList();
    } catch (e) {
      print('Error fetching itineraries: $e');
      return [];
    }
  }

  // Get all itineraries with their associated exhibits
  Future<List<ItineraryWithExhibits>> getItinerariesWithExhibits() async {
    try {
      final result = await connection.query('''
        SELECT i.itinerary_id, i.title, e.exhibit_id, e.title
        FROM Itineraries i
        LEFT JOIN Itinerary_Exhibit ie ON ie.itinerary_id = i.itinerary_id
        LEFT JOIN Exhibits e ON e.exhibit_id = ie.exhibit_id
        ORDER BY i.itinerary_id, ie.exhibit_order
      ''');

      final Map<int, ItineraryWithExhibits> itineraries = {};

      for (final row in result) {
        final itineraryId = row[0] as int;
        final itineraryTitle = row[1] as String;

        itineraries.putIfAbsent(
          itineraryId,
          () => ItineraryWithExhibits(
            itinerary_id: itineraryId,
            title: itineraryTitle,
            exhibits: [],
          ),
        );

        if (row[2] != null) {
          itineraries[itineraryId]!.exhibits.add(
            ExhibitLite(
              exhibit_id: row[2] as int,
              title: row[3] as String,
            ),
          );
        }
      }

      return itineraries.values.toList();
    } catch (e) {
      print('Error fetching itineraries with exhibits: $e');
      return [];
    }
  }

  // Get a specific itinerary with its exhibits
  Future<ItineraryWithExhibits?> getItineraryById(int itineraryId) async {
    try {
      final result = await connection.query('''
        SELECT i.itinerary_id, i.title, e.exhibit_id, e.title
        FROM Itineraries i
        LEFT JOIN Itinerary_Exhibit ie ON ie.itinerary_id = i.itinerary_id
        LEFT JOIN Exhibits e ON e.exhibit_id = ie.exhibit_id
        WHERE i.itinerary_id = @itineraryId
        ORDER BY ie.exhibit_order
      ''', substitutionValues: {'itineraryId': itineraryId});

      if (result.isEmpty) return null;

      final firstRow = result.first;
      final itinerary = ItineraryWithExhibits(
        itinerary_id: firstRow[0] as int,
        title: firstRow[1] as String,
        exhibits: [],
      );

      for (final row in result) {
        if (row[2] != null) {
          itinerary.exhibits.add(
            ExhibitLite(
              exhibit_id: row[2] as int,
              title: row[3] as String,
            ),
          );
        }
      }

      return itinerary;
    } catch (e) {
      print('Error fetching itinerary $itineraryId: $e');
      return null;
    }
  }

  // Get number of exhibits in an itinerary
  Future<int> getExhibitCount(int itineraryId) async {
    try {
      final result = await connection.query('''
        SELECT COUNT(*) as count
        FROM Itinerary_Exhibit
        WHERE itinerary_id = @itineraryId
      ''', substitutionValues: {'itineraryId': itineraryId});

      if (result.isEmpty) return 0;
      return result.first[0] as int;
    } catch (e) {
      print('Error counting exhibits for itinerary $itineraryId: $e');
      return 0;
    }
  }
}