class EngagementGroup {
  final String id;
  final String groupName;
  final String platform; // e.g., WhatsApp, Email
  final String link;

  EngagementGroup({
    required this.id,
    required this.groupName,
    required this.platform,
    required this.link,
  });

  // This factory constructor was missing. It's needed to create an
  // EngagementGroup object from the data retrieved from Firestore.
  factory EngagementGroup.fromFirestore(
      Map<String, dynamic> data, String documentId) {
    return EngagementGroup(
      id: documentId,
      groupName: data['groupName'] ?? '',
      platform: data['platform'] ?? '',
      link: data['link'] ?? '',
    );
  }
}
