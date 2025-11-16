class College {
  final String id;
  final String name;
  final String district;
  final String state;

  College({
    required this.id,
    required this.name,
    required this.district,
    required this.state,
  });

  factory College.fromFirestore(Map<String, dynamic> data, String documentId) {
    return College(
      id: documentId,
      name: data['name'] ?? '',
      district: data['district'] ?? '',
      state: data['state'] ?? '',
    );
  }
}
