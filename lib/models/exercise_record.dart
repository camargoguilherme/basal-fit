import 'package:cloud_firestore/cloud_firestore.dart';

class ExerciseRecord {
  final String id;
  final String exerciseId;
  final DateTime date;
  final int durationMinutes;
  final String? note;

  ExerciseRecord({
    required this.id,
    required this.exerciseId,
    required this.date,
    required this.durationMinutes,
    this.note,
  });

  factory ExerciseRecord.fromMap(Map<String, dynamic> map) {
    return ExerciseRecord(
      id: map['id'] as String,
      exerciseId: map['exerciseId'] as String,
      date: (map['date'] as Timestamp).toDate(),
      durationMinutes: map['durationMinutes'] as int,
      note: map['note'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exerciseId': exerciseId,
      'date': Timestamp.fromDate(date),
      'durationMinutes': durationMinutes,
      'note': note,
    };
  }
}
