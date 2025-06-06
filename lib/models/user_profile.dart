class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? profileImageUrl;
  final int? age;
  final String? gender;
  final double? height;
  final double? weight;
  final String? activityLevel;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
    this.age,
    this.gender,
    this.height,
    this.weight,
    this.activityLevel,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
      'activityLevel': activityLevel,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      age:
          map['age'] is String ? int.tryParse(map['age']) : map['age']?.toInt(),
      gender: map['gender'],
      height: map['height'] is String
          ? double.tryParse(map['height'])
          : map['height']?.toDouble(),
      weight: map['weight'] is String
          ? double.tryParse(map['weight'])
          : map['weight']?.toDouble(),
      activityLevel: map['activityLevel'],
      createdAt: map['createdAt'] is String
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: map['updatedAt'] is String
          ? DateTime.tryParse(map['updatedAt']) ?? DateTime.now()
          : DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
    );
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? profileImageUrl,
    int? age,
    String? gender,
    double? height,
    double? weight,
    String? activityLevel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      activityLevel: activityLevel ?? this.activityLevel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Calcula a Taxa Metabólica Basal usando a fórmula Mifflin-St Jeor
  double calculateTmb() {
    if (age == null || weight == null || height == null || gender == null) {
      return 0.0;
    }

    // Fórmula Mifflin-St Jeor
    // Homens: (10 × peso em kg) + (6.25 × altura em cm) - (5 × idade em anos) + 5
    // Mulheres: (10 × peso em kg) + (6.25 × altura em cm) - (5 × idade em anos) - 161

    double tmb = (10 * weight!) + (6.25 * height!) - (5 * age!);

    if (gender!.toLowerCase() == 'masculino') {
      tmb += 5;
    } else if (gender!.toLowerCase() == 'feminino') {
      tmb -= 161;
    }

    return tmb;
  }

  /// Calcula o Gasto Energético Total baseado na TMB e nível de atividade
  double calculateGet() {
    final tmb = calculateTmb();
    if (tmb == 0 || activityLevel == null) {
      return 0.0;
    }

    // Fatores de atividade física
    switch (activityLevel!.toLowerCase()) {
      case 'sedentario':
        return tmb * 1.2;
      case 'leve':
        return tmb * 1.375;
      case 'moderado':
        return tmb * 1.55;
      case 'ativo':
        return tmb * 1.725;
      case 'muito_ativo':
      case 'muitoativo':
        return tmb * 1.725;
      case 'extremamente_ativo':
      case 'extremamenteativo':
        return tmb * 1.9;
      default:
        return tmb * 1.2; // Default para sedentário
    }
  }

  /// Verifica se o perfil tem todos os dados necessários para cálculos
  bool get isProfileComplete {
    return age != null &&
        weight != null &&
        height != null &&
        gender != null &&
        activityLevel != null &&
        _isValidAge &&
        _isValidWeight &&
        _isValidHeight;
  }

  bool get _isValidAge {
    return age != null && age! >= 13 && age! <= 120;
  }

  bool get _isValidWeight {
    return weight != null && weight! >= 15.0 && weight! <= 450.0;
  }

  bool get _isValidHeight {
    return height != null && height! >= 45.0 && height! <= 295.0;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserProfile &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.profileImageUrl == profileImageUrl &&
        other.age == age &&
        other.gender == gender &&
        other.height == height &&
        other.weight == weight &&
        other.activityLevel == activityLevel;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        email.hashCode ^
        (profileImageUrl?.hashCode ?? 0) ^
        (age?.hashCode ?? 0) ^
        (gender?.hashCode ?? 0) ^
        (height?.hashCode ?? 0) ^
        (weight?.hashCode ?? 0) ^
        (activityLevel?.hashCode ?? 0);
  }
}
