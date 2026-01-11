// Gaëtan Veuillet
// 2025
// Data Access Object for Favorites

import 'package:postgres/postgres.dart';
import 'package:visitor_app/data/exhibit.dart';

class FavoritesDao {
  final PostgreSQLConnection connection;

  FavoritesDao(this.connection);

  // Add an exhibit to favorites
  Future<bool> addFavorite({
    required int sessionId,
    required int exhibitId,
  }) async {
    try {
      await connection.execute('''
        INSERT INTO Favorites (session_id, exhibit_id)
        VALUES (@sessionId, @exhibitId)
        ON CONFLICT (session_id, exhibit_id) DO NOTHING
      ''', substitutionValues: {
        'sessionId': sessionId,
        'exhibitId': exhibitId,
      });
      
      print('Favorite added: exhibit $exhibitId for session $sessionId');
      return true;
    } catch (e) {
      print('Error adding favorite: $e');
      return false;
    }
  }

  // Remove an exhibit from favorites
  Future<bool> removeFavorite({
    required int sessionId,
    required int exhibitId,
  }) async {
    try {
      await connection.execute('''
        DELETE FROM Favorites
        WHERE session_id = @sessionId AND exhibit_id = @exhibitId
      ''', substitutionValues: {
        'sessionId': sessionId,
        'exhibitId': exhibitId,
      });
      
      print('Favorite removed: exhibit $exhibitId for session $sessionId');
      return true;
    } catch (e) {
      print('Error removing favorite: $e');
      return false;
    }
  }

  // Check if an exhibit is a favorite for a session
  Future<bool> isFavorite({
    required int sessionId,
    required int exhibitId,
  }) async {
    try {
      final result = await connection.query('''
        SELECT 1 FROM Favorites
        WHERE session_id = @sessionId AND exhibit_id = @exhibitId
        LIMIT 1
      ''', substitutionValues: {
        'sessionId': sessionId,
        'exhibitId': exhibitId,
      });
      
      return result.isNotEmpty;
    } catch (e) {
      print('Error checking favorite: $e');
      return false;
    }
  }

  // Get all favorite exhibits for a session (with details)
  Future<List<ExhibitLite>> getFavorites({
    required int sessionId,
  }) async {
    try {
      final result = await connection.query('''
        SELECT e.exhibit_id, e.title
        FROM Favorites f
        JOIN Exhibits e ON e.exhibit_id = f.exhibit_id
        WHERE f.session_id = @sessionId
        ORDER BY f.added_at DESC
      ''', substitutionValues: {
        'sessionId': sessionId,
      });

      return result.map((row) {
        return ExhibitLite(
          exhibit_id: row[0] as int,
          title: row[1] as String,
        );
      }).toList();
    } catch (e) {
      print('Error fetching favorites: $e');
      return [];
    }
  }

  // Toggle favorite status (add if not exists, remove if exists)
  Future<bool> toggleFavorite({
    required int sessionId,
    required int exhibitId,
  }) async {
    try {
      final isFav = await isFavorite(
        sessionId: sessionId,
        exhibitId: exhibitId,
      );

      if (isFav) {
        return await removeFavorite(
          sessionId: sessionId,
          exhibitId: exhibitId,
        );
      } else {
        return await addFavorite(
          sessionId: sessionId,
          exhibitId: exhibitId,
        );
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      return false;
    }
  }

  // Get favorite count for a session
  Future<int> getFavoritesCount({
    required int sessionId,
  }) async {
    try {
      final result = await connection.query('''
        SELECT COUNT(*) as count
        FROM Favorites
        WHERE session_id = @sessionId
      ''', substitutionValues: {
        'sessionId': sessionId,
      });

      if (result.isEmpty) return 0;
      return result.first[0] as int;
    } catch (e) {
      print('Error counting favorites: $e');
      return 0;
    }
  }

  // Clear all favorites for a session
  Future<bool> clearAllFavorites({
    required int sessionId,
  }) async {
    try {
      await connection.execute('''
        DELETE FROM Favorites
        WHERE session_id = @sessionId
      ''', substitutionValues: {
        'sessionId': sessionId,
      });
      
      print('All favorites cleared for session $sessionId');
      return true;
    } catch (e) {
      print('Error clearing favorites: $e');
      return false;
    }
  }
}