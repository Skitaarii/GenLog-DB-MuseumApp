// Gaëtan Veuillet
// 2025
// Data Access Object for Itinerary (Visitor - Read Only)
// Handles all read operations for itineraries in the visitor application

import 'package:postgres/postgres.dart';
import 'package:visitor_app/data/itinerary.dart';
import 'package:visitor_app/data/exhibit.dart';
import 'package:visitor_app/utils/language_manager.dart';

class ItineraryDao {
  final PostgreSQLConnection connection;

  ItineraryDao(this.connection);

  // Get all itineraries (basic info only - without exhibits)
  // Used for simple list displays where exhibit details are not required
  Future<List<Itinerary>> getAllItineraries() async {
    try {
      final result = await connection.query(
        'SELECT itinerary_id, title FROM itineraries ORDER BY itinerary_id',
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
  // Returns complete itinerary data including all contained exhibits
  Future<List<ItineraryWithExhibits>> getItinerariesWithExhibits() async {
    try {
      final langColumn = LanguageManager().dbColumnName; // FR / EN / IT / DE

      // Complex query joining itineraries with exhibits through junction table
      final result = await connection.query('''
        SELECT
          i.itinerary_id,
          i.title_$langColumn,          -- Language-specific title
          e.exhibit_id,
          e.title                        -- Exhibit title (language independent)
        FROM itineraries i
        LEFT JOIN itinerary_exhibit ie ON ie.itinerary_id = i.itinerary_id
        LEFT JOIN exhibits e ON e.exhibit_id = ie.exhibit_id
        ORDER BY i.itinerary_id, ie.exhibit_order  -- Maintain exhibit order
      ''');

      // Map to group exhibits by itinerary
      final Map<int, ItineraryWithExhibits> itineraries = {};

      for (final row in result) {
        final itineraryId = row[0] as int;
        final itineraryTitle = row[1] as String;

        // Create itinerary entry if it doesn't exist
        itineraries.putIfAbsent(
          itineraryId,
          () => ItineraryWithExhibits(
            itinerary_id: itineraryId,
            title: itineraryTitle,
            exhibits: [],
          ),
        );

        // Add exhibit to itinerary if present (some itineraries may be empty)
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

  // Get a specific itinerary with its exhibits by ID
  // Used when navigating to a specific itinerary detail page
  Future<ItineraryWithExhibits?> getItineraryById(int itineraryId) async {
    try {
      final result = await connection.query('''
        SELECT i.itinerary_id, i.title, e.exhibit_id, e.title
        FROM itineraries i
        LEFT JOIN itinerary_exhibit ie ON ie.itinerary_id = i.itinerary_id
        LEFT JOIN exhibits e ON e.exhibit_id = ie.exhibit_id
        WHERE i.itinerary_id = @itineraryId
        ORDER BY ie.exhibit_order  -- Maintain the intended exhibit order
      ''', substitutionValues: {'itineraryId': itineraryId});

      if (result.isEmpty) return null; // Itinerary not found

      // First row contains itinerary info
      final firstRow = result.first;
      final itinerary = ItineraryWithExhibits(
        itinerary_id: firstRow[0] as int,
        title: firstRow[1] as String,
        exhibits: [],
      );

      // Add all exhibits from remaining rows
      for (final row in result) {
        if (row[2] != null) { // Check if exhibit exists (LEFT JOIN may return null)
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

  // Get number of exhibits in a specific itinerary
  // Used for summary displays and statistics
  Future<int> getExhibitCount(int itineraryId) async {
    try {
      final result = await connection.query('''
        SELECT COUNT(*) as count
        FROM itinerary_exhibit
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