import 'package:empower_ananya/models/program_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProgramListItem extends StatelessWidget {
  final Program program;
  final VoidCallback? onTap; // Add an onTap callback property

  const ProgramListItem({
    super.key,
    required this.program,
    this.onTap, // Accept the onTap callback in the constructor
  });

  IconData _getIconForProgramType(ProgramType type) {
    switch (type) {
      case ProgramType.course:
        return Icons.school;
      case ProgramType.internship:
        return Icons.work;
      case ProgramType.mentorship:
        return Icons.people;
      case ProgramType.training:
        return Icons.model_training;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(_getIconForProgramType(program.type)),
        ),
        title: Text(program.title),
        subtitle: Text(
            '${program.involvedScholars.length} Scholars • ${DateFormat.yMMMd().format(program.date)}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap, // Use the passed-in onTap callback
      ),
    );
  }
}
