class Exercise implements Comparable<Exercise> {
  final String id;
  final String name;
  final String? description;
  final String category;
  final double caloriesPerMinute;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  Exercise({
    required this.id,
    required this.name,
    this.description,
    required this.category,
    required this.caloriesPerMinute,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Calcula calorias queimadas para uma duração específica em minutos
  double calculateCalories(int durationMinutes) {
    if (durationMinutes <= 0 || caloriesPerMinute < 0) {
      return 0.0;
    }
    return caloriesPerMinute * durationMinutes;
  }

  /// Verifica se o exercício tem dados válidos
  bool get isValid {
    return name.isNotEmpty && category.isNotEmpty && caloriesPerMinute >= 0;
  }

  /// Verifica se é exercício de cardio
  bool get isCardio {
    return category.toLowerCase().contains('cardio');
  }

  /// Verifica se é exercício de força
  bool get isStrength {
    return category.toLowerCase().contains('força') ||
        category.toLowerCase().contains('force');
  }

  /// Verifica se é exercício de flexibilidade
  bool get isFlexibility {
    return category.toLowerCase().contains('flexibilidade') ||
        category.toLowerCase().contains('flexibility');
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      category: map['category'] as String,
      caloriesPerMinute: (map['caloriesPerMinute'] as num).toDouble(),
      isDefault: map['isDefault'] as bool? ?? false,
      createdAt: map['createdAt'] is String
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: map['updatedAt'] is String
          ? DateTime.tryParse(map['updatedAt']) ?? DateTime.now()
          : DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'caloriesPerMinute': caloriesPerMinute,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Exercise copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    double? caloriesPerMinute,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      caloriesPerMinute: caloriesPerMinute ?? this.caloriesPerMinute,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Exercise &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.category == category &&
        other.caloriesPerMinute == caloriesPerMinute &&
        other.isDefault == isDefault;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        (description?.hashCode ?? 0) ^
        category.hashCode ^
        caloriesPerMinute.hashCode ^
        isDefault.hashCode;
  }

  @override
  int compareTo(Exercise other) {
    // Primeiro compara por categoria, depois por nome
    final categoryComparison = category.compareTo(other.category);
    if (categoryComparison != 0) {
      return categoryComparison;
    }
    return name.compareTo(other.name);
  }

  @override
  String toString() {
    return 'Exercise(id: $id, name: $name, category: $category, caloriesPerMinute: $caloriesPerMinute)';
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
