import 'package:empower_ananya/models/college_model.dart';
import 'package:empower_ananya/models/program_model.dart';
import 'package:empower_ananya/screens/add_event_screen.dart';
import 'package:empower_ananya/screens/details/program_detail_screen.dart';
import 'package:empower_ananya/services/firestore_service.dart';
import 'package:empower_ananya/widgets/program_lists_item.dart';
import 'package:flutter/material.dart';

class CollegeDetailScreen extends StatelessWidget {
  final College college;
  const CollegeDetailScreen({super.key, required this.college});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: Text(college.name),
      ),
      body: StreamBuilder<List<Program>>(
        stream: firestoreService.getProgramsForCollege(college.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No programs found for this college.',
                textAlign: TextAlign.center,
              ),
            );
          }

          final programs = snapshot.data!;

          return ListView.builder(
            itemCount: programs.length,
            itemBuilder: (context, index) {
              final program = programs[index];
              return ProgramListItem(
                program: program,
                // This onTap function makes each program in the list clickable
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProgramDetailScreen(program: program),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEventScreen(college: college),
            ),
          );
        },
        label: const Text('Add Program'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
