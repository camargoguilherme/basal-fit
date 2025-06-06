import 'package:cloud_firestore/cloud_firestore.dart';

class TMBRecord {
  final String id;
  final DateTime date;
  final double weight;
  final double height;
  final int age;
  final String gender;
  final double tmb;

  TMBRecord({
    required this.id,
    required this.date,
    required this.weight,
    required this.height,
    required this.age,
    required this.gender,
    required this.tmb,
  });

  factory TMBRecord.fromMap(Map<String, dynamic> map) {
    return TMBRecord(
      id: map['id'] as String,
      date: (map['date'] as Timestamp).toDate(),
      weight: (map['weight'] as num).toDouble(),
      height: (map['height'] as num).toDouble(),
      age: map['age'] as int,
      gender: map['gender'] as String,
      tmb: (map['tmb'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': Timestamp.fromDate(date),
      'weight': weight,
      'height': height,
      'age': age,
      'gender': gender,
      'tmb': tmb,
    };
  }
}
