class Exercise {
  final String id;
  final String name;
  final String category;
  final double caloriesPerMinute;

  Exercise({
    required this.id,
    required this.name,
    required this.category,
    required this.caloriesPerMinute,
  });

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      caloriesPerMinute: (map['caloriesPerMinute'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'caloriesPerMinute': caloriesPerMinute,
    };
  }
}

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exerciseId': exerciseId,
      'date': date.toIso8601String(),
      'durationMinutes': durationMinutes,
      'note': note,
    };
  }

  factory ExerciseRecord.fromMap(Map<String, dynamic> map) {
    return ExerciseRecord(
      id: map['id'],
      exerciseId: map['exerciseId'],
      date: DateTime.parse(map['date']),
      durationMinutes: map['durationMinutes'],
      note: map['note'],
    );
  }
}
