import 'package:empower_ananya/main.dart'; // Import for GlassCard
import 'package:empower_ananya/models/college_model.dart';
import 'package:empower_ananya/screens/details/college_detail_screen.dart';
import 'package:empower_ananya/services/firestore_service.dart';
import 'package:flutter/material.dart';

class CollegesTab extends StatelessWidget {
  const CollegesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: Colors.transparent, // Important for the glass effect
      body: StreamBuilder<List<College>>(
        stream: firestoreService.getColleges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No colleges found.'));
          }

          final colleges = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(
                16, 16, 16, 90), // Padding for AppBar and BottomNav
            itemCount: colleges.length,
            itemBuilder: (context, index) {
              final college = colleges[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                // --- REDESIGNED WITH GLASS CARD ---
                child: GlassCard(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    leading: CircleAvatar(
                      backgroundColor: Colors.white.withAlpha(26),
                      child:
                          const Icon(Icons.school_rounded, color: Colors.white),
                    ),
                    title: Text(
                      college.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Text(
                      '${college.district}, ${college.state}',
                      style: TextStyle(color: Colors.white.withAlpha(179)),
                    ),
                    trailing:
                        const Icon(Icons.chevron_right, color: Colors.white),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CollegeDetailScreen(college: college),
                        ),
                      );
                    },
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
