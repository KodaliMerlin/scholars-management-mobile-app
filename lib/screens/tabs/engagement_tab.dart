import 'package:empower_ananya/main.dart'; // Import for GlassCard
import 'package:empower_ananya/models/engagement_model.dart';
import 'package:empower_ananya/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EngagementTab extends StatelessWidget {
  const EngagementTab({super.key});

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();
    return Scaffold(
      backgroundColor: Colors.transparent, // Important for the glass effect
      body: StreamBuilder<List<EngagementGroup>>(
        stream: firestoreService.getEngagementGroups(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No engagement groups found.'));
          }

          final groups = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(
                16, 16, 16, 90), // Padding for AppBar and BottomNav
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                // --- REDESIGNED WITH GLASS CARD ---
                child: GlassCard(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    leading: CircleAvatar(
                      backgroundColor: Colors.white.withAlpha(26),
                      child: Icon(
                        group.platform.toLowerCase() == 'whatsapp'
                            ? Icons.chat_rounded
                            : Icons.email_rounded,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      group.groupName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Text(
                      group.platform,
                      style: TextStyle(color: Colors.white.withAlpha(179)),
                    ),
                    trailing:
                        const Icon(Icons.open_in_new, color: Colors.white),
                    onTap: () => _launchURL(group.link),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
