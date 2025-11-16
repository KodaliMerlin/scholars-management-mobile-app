import 'package:empower_ananya/models/scholar_model.dart';
import 'package:flutter/material.dart';

class ScholarDetailScreen extends StatelessWidget {
  final Scholar scholar;
  const ScholarDetailScreen({super.key, required this.scholar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(scholar.fullName),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(scholar.fullName, scholar.collegeName, context),
            const SizedBox(height: 24),
            _buildSectionTitle('Personal Information', context),
            _buildInfoCard([
              _buildInfoRow('Email:', scholar.email),
              _buildInfoRow('Mobile:', scholar.mobileNumber),
            ]),
            const SizedBox(height: 24),
            _buildSectionTitle('Family Background', context),
            _buildInfoCard([
              _buildInfoRow("Father's Name:", scholar.fatherName),
              _buildInfoRow("Father's Occupation:", scholar.fatherOccupation),
              _buildInfoRow("Mother's Name:", scholar.motherName),
              _buildInfoRow("Mother's Occupation:", scholar.motherOccupation),
              _buildInfoRow('Annual Income:', scholar.annualIncome),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String name, String college, BuildContext context) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.pink.shade100,
            child: Text(
              name.isNotEmpty ? name[0] : 'S',
              // Corrected text style
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge
                  ?.copyWith(color: Colors.pink.shade800),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            // Corrected text style
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          Text(
            college,
            // Corrected text style
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        // Corrected text style
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120, // Fixed width for the title
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
