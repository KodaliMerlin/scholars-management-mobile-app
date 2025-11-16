import 'package:empower_ananya/models/program_model.dart';
import 'package:empower_ananya/models/scholar_model.dart';
import 'package:empower_ananya/services/firestore_service.dart';
import 'package:flutter/material.dart';

class ProgramDetailScreen extends StatefulWidget {
  final Program program;
  const ProgramDetailScreen({super.key, required this.program});

  @override
  State<ProgramDetailScreen> createState() => _ProgramDetailScreenState();
}

class _ProgramDetailScreenState extends State<ProgramDetailScreen> {
  late Future<List<Scholar>> _involvedScholarsFuture;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    // Fetch the full scholar details when the screen is first loaded
    _involvedScholarsFuture =
        _firestoreService.getScholarsByIds(widget.program.involvedScholars);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.program.title),
      ),
      body: FutureBuilder<List<Scholar>>(
        future: _involvedScholarsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('No scholars are assigned to this program.'));
          }

          final scholars = snapshot.data!;

          return ListView.builder(
            itemCount: scholars.length,
            itemBuilder: (context, index) {
              final scholar = scholars[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(scholar.fullName.isNotEmpty
                        ? scholar.fullName[0]
                        : 'S'),
                  ),
                  title: Text(scholar.fullName),
                  subtitle: Text(scholar.collegeName),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
