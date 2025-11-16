class Scholar {
  final String id;
  final String fullName;
  final String collegeName;
  final String email;
  final String mobileNumber;
  final String fatherName;
  final String fatherEducation;
  final String fatherOccupation;
  final String motherName;
  final String motherEducation;
  final String motherOccupation;
  final String annualIncome;
  final String state; // *** NEW FIELD ADDED ***

  Scholar({
    required this.id,
    required this.fullName,
    required this.collegeName,
    required this.email,
    required this.mobileNumber,
    required this.fatherName,
    required this.fatherEducation,
    required this.fatherOccupation,
    required this.motherName,
    required this.motherEducation,
    required this.motherOccupation,
    required this.annualIncome,
    required this.state, // *** NEW FIELD ADDED ***
  });

  factory Scholar.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Scholar(
      id: documentId,
      fullName: data['fullName'] ?? '',
      collegeName: data['collegeName'] ?? '',
      email: data['email'] ?? '',
      mobileNumber: (data['mobileNumber'] ?? '').toString(),
      fatherName: data['fatherName'] ?? '',
      fatherEducation: data['fatherEducation'] ?? '',
      fatherOccupation: data['fatherOccupation'] ?? '',
      motherName: data['motherName'] ?? '',
      motherEducation: data['motherEducation'] ?? '',
      motherOccupation: data['motherOccupation'] ?? '',
      annualIncome: data['annualIncome'] ?? '',
      state: data['state'] ?? 'Unknown', // *** NEW FIELD ADDED ***
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'fullName': fullName,
      'collegeName': collegeName,
      'email': email,
      'mobileNumber': mobileNumber,
      'fatherName': fatherName,
      'fatherEducation': fatherEducation,
      'fatherOccupation': fatherOccupation,
      'motherName': motherName,
      'motherEducation': motherEducation,
      'motherOccupation': motherOccupation,
      'annualIncome': annualIncome,
      'state': state, // *** NEW FIELD ADDED ***
    };
  }
}
