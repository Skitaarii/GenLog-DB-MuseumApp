//@ : Veuillet Gaëtan
// 2025
// Data Access Object for User entity


import 'package:postgres/postgres.dart';
import 'package:trying_flutter/data/exhibit.dart';

class ExhibitDao {
  final PostgreSQLConnection connection;

  ExhibitDao(this.connection);

  Future<void> insertExhibit({
    required String title,
    DateTime? startDate,
    DateTime? finalDate,
  }) async {
    await connection.query(
      '''
      INSERT INTO exhibits(title, start_date, final_date)
      VALUES (@title, @start_date, @final_date)
      ''',
      substitutionValues: {
        'title': title,
        'start_date': startDate,
        'final_date': finalDate,
      },
    );
  }

  Future<void> updateFinalDate({
    required int exhibitId,
    required DateTime finalDate,
  }) async {
    await connection.query(
      '''
      UPDATE exhibits
      SET final_date = @final_date
      WHERE exhibit_id = @exhibit_id
      ''',
      substitutionValues: {
        'final_date': finalDate,
        'exhibit_id': exhibitId,
      },
    );
  }

  Future<List<List<dynamic>>> getExhibitById(int id) async {
    return await connection.query(
      '''
      SELECT * FROM exhibits WHERE exhibit_id = @id
      ''',
      substitutionValues: {'id': id},
    );
  }

  Future<List<Exhibit>> getAllExhibits() async {
    final result = await connection.query(
      'SELECT exhibit_id, title, start_date, final_date FROM exhibits',
    );

    return result.map((row){
      return Exhibit(
        exhibit_id: row[0] as int,
        title : row[1] as String,
        startDate: row[4] as DateTime?,
        finalDate: row[5] as DateTime?,
      );
    }).toList();
  }
}

