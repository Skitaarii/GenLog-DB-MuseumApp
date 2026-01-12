// Gaëtan Veuillet
// 2025
// Data Access Object for Itinerary management
// Handles CRUD operations for museum itineraries and their exhibit associations

import 'package:postgres/postgres.dart';
import 'package:editor_app/data/itinerary.dart';
import 'package:editor_app/data/exhibit.dart';

class ItineraryDao {
  final PostgreSQLConnection connection;

  ItineraryDao(this.connection);

  // Create a new itinerary and return its ID
  Future<int> createItinerary({required String title}) async {
    final result = await connection.query(
      '''
      INSERT INTO Itineraries(title_en)
      VALUES (@title)
      RETURNING itinerary_id
      ''',
      substitutionValues: {
        'title': title,
      },
    );
    return result.first[0] as int;
  }

  // Get all itineraries (basic info only)
  Future<List<Itinerary>> getAllItineraries() async {
    final result = await connection.query(
      'SELECT itinerary_id, title_en FROM Itineraries ORDER BY i.itinerary_id, ie.exhibit_order',
    );

    return result.map((row) {
      return Itinerary(
        itinerary_id: row[0] as int,
        title: row[1] as String,
      );
    }).toList();
  }

  // Get all itineraries with their associated exhibits
  // Uses LEFT JOIN to include itineraries with no exhibits
  Future<List<ItineraryWithExhibits>> getItinerariesWithExhibits() async {
    final result = await connection.query('''
      SELECT 
        i.itinerary_id,
        i.title_EN,
        e.exhibit_id,
        e.title,
        ie.exhibit_order
      FROM Itineraries i
      LEFT JOIN Itinerary_Exhibit ie ON ie.itinerary_id = i.itinerary_id
      LEFT JOIN Exhibits e ON e.exhibit_id = ie.exhibit_id
      ORDER BY i.itinerary_id, ie.exhibit_order
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

      // Add exhibit to itinerary if present (LEFT JOIN may return null)
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
  }

  // Get a specific itinerary with its exhibits
  Future<ItineraryWithExhibits?> getItineraryById(int itineraryId) async {
    final result = await connection.query('''
      SELECT i.itinerary_id, i.title_EN, e.exhibit_id, e.title
      FROM Itineraries i
      LEFT JOIN Itinerary_Exhibit ie ON ie.itinerary_id = i.itinerary_id
      LEFT JOIN Exhibits e ON e.exhibit_id = ie.exhibit_id
      WHERE i.itinerary_id = @itineraryId
    ''', substitutionValues: {'itineraryId': itineraryId});

    if (result.isEmpty) return null; // Itinerary not found

    // Create itinerary from first row
    final firstRow = result.first;
    final itinerary = ItineraryWithExhibits(
      itinerary_id: firstRow[0] as int,
      title: firstRow[1] as String,
      exhibits: [],
    );

    // Add all exhibits from result set
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
  }

  // Update exhibits in an itinerary (replaces all existing associations)
  // Maintains exhibit order based on list position
  Future<void> updateItineraryExhibits(
    int itineraryId,
    List<int> exhibitIds,
  ) async {
    // Remove all existing exhibit associations
    await connection.execute(
      'DELETE FROM Itinerary_Exhibit WHERE itinerary_id = @itineraryId',
      substitutionValues: {'itineraryId': itineraryId},
    );

    // Insert new associations with order preserved
    for (int i = 0; i < exhibitIds.length; i++) {
      await connection.execute(
        '''
        INSERT INTO Itinerary_Exhibit 
          (itinerary_id, exhibit_id, exhibit_order)
        VALUES 
          (@itineraryId, @exhibitId, @order)
        ''',
        substitutionValues: {
          'itineraryId': itineraryId,
          'exhibitId': exhibitIds[i],
          'order': i, // Use list index as order
        },
      );
    }
  }

  // Update itinerary title
  Future<void> updateItinerary(
    int itineraryId, {
    required String title,
  }) async {
    await connection.execute(
      '''
      UPDATE Itineraries
      SET title_EN = @title
      WHERE itinerary_id = @id
      ''',
      substitutionValues: {
        'title': title,
        'id': itineraryId,
      },
    );
  }

  // Add a single exhibit to an itinerary
  // Automatically calculates next available order position
  Future<void> addExhibitToItinerary(int itineraryId, int exhibitId) async {
    // Find maximum order value to determine next position
    final result = await connection.query(
      '''
      SELECT COALESCE(MAX(exhibit_order), -1) + 1
      FROM Itinerary_Exhibit
      WHERE itinerary_id = @itineraryId
      ''',
      substitutionValues: {'itineraryId': itineraryId},
    );

    final nextOrder = result.first[0] as int;

    // Insert exhibit at calculated position
    await connection.execute(
      '''
      INSERT INTO Itinerary_Exhibit 
        (itinerary_id, exhibit_id, exhibit_order)
      VALUES 
        (@itineraryId, @exhibitId, @order)
      ''',
      substitutionValues: {
        'itineraryId': itineraryId,
        'exhibitId': exhibitId,
        'order': nextOrder,
      },
    );
  }

  // Remove a single exhibit from an itinerary
  Future<void> removeExhibitFromItinerary(int itineraryId, int exhibitId) async {
    await connection.execute(
      'DELETE FROM Itinerary_Exhibit WHERE itinerary_id = @itineraryId AND exhibit_id = @exhibitId',
      substitutionValues: {'itineraryId': itineraryId, 'exhibitId': exhibitId},
    );
  }

  // Delete an itinerary and all its exhibit associations
  // Performed in two steps due to foreign key constraints
  Future<void> deleteItinerary(int itineraryId) async {
    // First delete exhibit associations
    await connection.execute(
      'DELETE FROM Itinerary_Exhibit WHERE itinerary_id = @id',
      substitutionValues: {'id': itineraryId},
    );

    // Then delete the itinerary itself
    await connection.execute(
      'DELETE FROM Itineraries WHERE itinerary_id = @id',
      substitutionValues: {'id': itineraryId},
    );
  }

  // Get all exhibits (helper method for selection in editor)
  // Returns lightweight exhibit objects for dropdowns and selection lists
  Future<List<ExhibitLite>> getAllExhibits() async {
    final result = await connection.query(
      'SELECT exhibit_id, title FROM Exhibits ORDER BY exhibit_id',
    );

    return result.map((row) {
      return ExhibitLite(
        exhibit_id: row[0] as int,
        title: row[1] as String,
      );
    }).toList();
  }
}