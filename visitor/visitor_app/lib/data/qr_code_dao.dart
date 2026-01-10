// Benno WEber
// 2025
// Data Access Object for QR Code entity

import 'package:postgres/postgres.dart';

class QRCodeDao {
  final PostgreSQLConnection connection;

  QRCodeDao(this.connection);

  /// Check if a QR code entry already exists for this exhibit and room
  Future<bool> qrCodeExists(int exhibitId, int roomId) async {
    final result = await connection.query(
      '''
      SELECT QR_id FROM QR_Code 
      WHERE exhibit_id = @exhibitId AND room_id = @roomId
      ''',
      substitutionValues: {
        'exhibitId': exhibitId,
        'roomId': roomId,
      },
    );
    
    return result.isNotEmpty;
  }

  /// Insert a new QR code entry (called when first scanned)
  Future<int?> insertQRCode({
    required int exhibitId,
    required int roomId,
    String? qrImagePath,
  }) async {
    try {
      // Check if already exists
      if (await qrCodeExists(exhibitId, roomId)) {
        print('QR code already exists for exhibit $exhibitId, room $roomId');
        return null;
      }

      final result = await connection.query(
        '''
        INSERT INTO QR_Code(exhibit_id, room_id, QR_img_path)
        VALUES (@exhibitId, @roomId, @qrImagePath)
        RETURNING QR_id
        ''',
        substitutionValues: {
          'exhibitId': exhibitId,
          'roomId': roomId,
          'qrImagePath': qrImagePath,
        },
      );

      final qrId = result.first[0] as int;
      print('Created QR code entry: QR_id=$qrId, exhibit_id=$exhibitId, room_id=$roomId');
      return qrId;
    } catch (e) {
      print('Error inserting QR code: $e');
      return null;
    }
  }

  /// Get all QR codes
  Future<List<Map<String, dynamic>>> getAllQRCodes() async {
    final result = await connection.query(
      '''
      SELECT qr.QR_id, qr.exhibit_id, qr.room_id, qr.QR_img_path,
             e.title as exhibit_title, r.name as room_name
      FROM QR_Code qr
      LEFT JOIN Exhibits e ON qr.exhibit_id = e.exhibit_id
      LEFT JOIN Room r ON qr.room_id = r.room_id
      ORDER BY qr.QR_id
      ''',
    );

    return result.map((row) {
      return {
        'qr_id': row[0] as int,
        'exhibit_id': row[1] as int,
        'room_id': row[2] as int,
        'qr_img_path': row[3] as String?,
        'exhibit_title': row[4] as String?,
        'room_name': row[5] as String?,
      };
    }).toList();
  }

  /// Get QR code by exhibit and room
  Future<Map<String, dynamic>?> getQRCode(int exhibitId, int roomId) async {
    final result = await connection.query(
      '''
      SELECT qr.QR_id, qr.exhibit_id, qr.room_id, qr.QR_img_path,
             e.title as exhibit_title, r.name as room_name
      FROM QR_Code qr
      LEFT JOIN Exhibits e ON qr.exhibit_id = e.exhibit_id
      LEFT JOIN Room r ON qr.room_id = r.room_id
      WHERE qr.exhibit_id = @exhibitId AND qr.room_id = @roomId
      ''',
      substitutionValues: {
        'exhibitId': exhibitId,
        'roomId': roomId,
      },
    );

    if (result.isEmpty) return null;

    final row = result.first;
    return {
      'qr_id': row[0] as int,
      'exhibit_id': row[1] as int,
      'room_id': row[2] as int,
      'qr_img_path': row[3] as String?,
      'exhibit_title': row[4] as String?,
      'room_name': row[5] as String?,
    };
  }

  /// Delete a QR code entry
  Future<bool> deleteQRCode(int qrId) async {
    try {
      await connection.execute(
        'DELETE FROM QR_Code WHERE QR_id = @qrId',
        substitutionValues: {'qrId': qrId},
      );
      print('Deleted QR code: QR_id=$qrId');
      return true;
    } catch (e) {
      print('Error deleting QR code: $e');
      return false;
    }
  }

  /// Update QR code image path
  Future<bool> updateQRImagePath(int qrId, String imagePath) async {
    try {
      await connection.execute(
        '''
        UPDATE QR_Code 
        SET QR_img_path = @imagePath
        WHERE QR_id = @qrId
        ''',
        substitutionValues: {
          'qrId': qrId,
          'imagePath': imagePath,
        },
      );
      print('Updated QR code image path: QR_id=$qrId');
      return true;
    } catch (e) {
      print('Error updating QR code image path: $e');
      return false;
    }
  }
}