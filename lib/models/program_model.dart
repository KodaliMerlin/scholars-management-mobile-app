import 'package:cloud_firestore/cloud_firestore.dart';

enum ProgramType {
  course,
  training,
  internship,
  mentorship;

  static ProgramType fromString(String type) {
    return ProgramType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => ProgramType.course,
    );
  }
}

class Program {
  final String id;
  final String title;
  final ProgramType type;
  final DateTime date;
  final List<String> involvedScholars;
  final bool isGlobal; // *** NEW FIELD ADDED ***

  Program({
    required this.id,
    required this.title,
    required this.type,
    required this.date,
    required this.involvedScholars,
    this.isGlobal = false, // Default to false
  });

  factory Program.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Program(
      id: documentId,
      title: data['title'] ?? '',
      type: ProgramType.fromString(data['type'] ?? 'course'),
      date: (data['date'] as Timestamp).toDate(),
      involvedScholars: List<String>.from(data['involvedScholars'] ?? []),
      isGlobal: data['isGlobal'] ?? false, // *** NEW FIELD ADDED ***
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'type': type.name,
      'date': Timestamp.fromDate(date),
      'involvedScholars': involvedScholars,
      'isGlobal': isGlobal, // *** NEW FIELD ADDED ***
    };
  }
}
