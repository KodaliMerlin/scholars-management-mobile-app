import 'package:empower_ananya/main.dart'; // Import for GlassCard
import 'package:empower_ananya/models/program_model.dart';
import 'package:empower_ananya/models/scholar_model.dart';
import 'package:empower_ananya/screens/add_global_program_screen.dart';
import 'package:empower_ananya/screens/details/scholar_detail_screen.dart';
import 'package:empower_ananya/services/auth_service.dart';
import 'package:empower_ananya/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilesTab extends StatelessWidget {
  const ProfilesTab({super.key});

  // --- HELPER FUNCTIONS FOR COMMUNICATION ---

  void _launchEmail() async {
    const String googleFormUrl = 'https://forms.gle/3BwC7H3cHxbPYrsT7';

    // *** FIX: The 'path' is now an empty string to keep the "To" field blank. ***
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: '',
      query:
          'subject=Invitation to Empower Ananya Program&body=Please fill out this form to join: $googleFormUrl',
    );

    if (!await launchUrl(emailLaunchUri)) {
      debugPrint('Could not launch email');
    }
  }

  void _showBroadcastDialog(BuildContext context) {
    final TextEditingController messageController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0D1117).withAlpha(204),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Broadcast Message'),
          content: TextField(
            controller: messageController,
            decoration:
                const InputDecoration(hintText: "Enter your message here..."),
            autofocus: true,
            maxLines: 3,
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (messageController.text.isNotEmpty) {
                  _launchWhatsApp(messageController.text);
                  Navigator.pop(context);
                }
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }

  void _launchWhatsApp(String message) async {
    final Uri whatsappLaunchUri =
        Uri.parse('https://wa.me/?text=${Uri.encodeComponent(message)}');
    if (!await launchUrl(whatsappLaunchUri,
        mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch WhatsApp');
    }
  }

  Future<void> _launchEmailReminder(
      Program program, List<String> emails) async {
    final String subject = 'Reminder: ${program.title}';
    final String body = '''
      Hello Scholars,
      This is a reminder for the upcoming program:
      Program: ${program.title}
      Date: ${DateFormat.yMMMMd().format(program.date)}
      We look forward to your participation.
      Best regards,
      The Empower Ananya Foundation
    ''';
    final Uri emailLaunchUri = Uri(
        scheme: 'mailto',
        query:
            'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}&bcc=${emails.join(',')}');
    if (!await launchUrl(emailLaunchUri)) {
      debugPrint('Could not launch email reminder');
    }
  }

  Future<void> _launchWhatsAppReminder(Program program) async {
    final String message = '''
      *Program Reminder*
      Hello Scholars,
      This is a reminder for the upcoming program: *${program.title}* on *${DateFormat.yMMMMd().format(program.date)}*.
      See you there!
    ''';
    final Uri whatsappLaunchUri =
        Uri.parse('https://wa.me/?text=${Uri.encodeComponent(message)}');
    if (!await launchUrl(whatsappLaunchUri,
        mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch WhatsApp reminder');
    }
  }

  Future<void> _sendReminder(BuildContext context, Program program,
      FirestoreService firestoreService) async {
    final allScholarEmails = await firestoreService.getAllScholarEmails();
    if (!context.mounted) return;
    if (allScholarEmails.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('No scholar emails found to send reminders.')));
      return;
    }
    await _launchEmailReminder(program, allScholarEmails);
    if (!context.mounted) return;
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF0D1117).withAlpha(204),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Next Step'),
        content: const Text(
            'Email reminder draft created. Would you also like to send a reminder via WhatsApp?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('No, Finish')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _launchWhatsAppReminder(program);
            },
            child: const Text('Yes, Open WhatsApp'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUniversalProgramsSection(context, firestoreService),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: Text(
              "All Scholars",
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          Expanded(
              child: _buildScholarListWithButtons(context, firestoreService)),
        ],
      ),
    );
  }

  Widget _buildUniversalProgramsSection(
      BuildContext context, FirestoreService firestoreService) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Universal Programs",
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: StreamBuilder<List<Program>>(
              stream: firestoreService.getUniversalPrograms(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('No universal programs found.'));
                }
                final programs = snapshot.data!;
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: programs.length,
                  itemBuilder: (context, index) {
                    final program = programs[index];
                    return SizedBox(
                      width: 220,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: GlassCard(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(program.title,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 4),
                                    Text(
                                        DateFormat.yMMMd().format(program.date),
                                        style: TextStyle(
                                            color:
                                                Colors.white.withAlpha(179))),
                                  ],
                                ),
                                SizedBox(
                                  height: 30,
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.send, size: 16),
                                    label: const Text("Send Reminder",
                                        style: TextStyle(fontSize: 12)),
                                    onPressed: () => _sendReminder(
                                        context, program, firestoreService),
                                    style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        side: BorderSide(
                                            color: Colors.white.withAlpha(100)),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScholarListWithButtons(
      BuildContext context, FirestoreService firestoreService) {
    return StreamBuilder<List<Scholar>>(
      stream: firestoreService.getScholars(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildFloatingActionButtons(context);
        }
        final scholars = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
          itemCount: scholars.length + 1,
          itemBuilder: (context, index) {
            if (index < scholars.length) {
              final scholar = scholars[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: GlassCard(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.white.withAlpha(26),
                      child: Text(
                          scholar.fullName.isNotEmpty
                              ? scholar.fullName[0].toUpperCase()
                              : 'S',
                          style: const TextStyle(color: Colors.white)),
                    ),
                    title: Text(scholar.fullName.isNotEmpty
                        ? scholar.fullName
                        : 'Unnamed Scholar'),
                    subtitle: Text(scholar.collegeName,
                        style: TextStyle(color: Colors.white.withAlpha(179))),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ScholarDetailScreen(scholar: scholar)),
                      );
                    },
                  ),
                ),
              );
            } else {
              return _buildFloatingActionButtons(context);
            }
          },
        );
      },
    );
  }

  Widget _buildFloatingActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Wrap(
        spacing: 12.0,
        runSpacing: 12.0,
        alignment: WrapAlignment.center,
        children: [
          FloatingActionButton.extended(
            onPressed: _launchEmail,
            label: const Text('Add Scholar'),
            icon: const Icon(Icons.person_add),
            heroTag: 'addScholarBtn',
          ),
          FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AddGlobalProgramScreen()),
              );
            },
            label: const Text('Universal Program'),
            icon: const Icon(Icons.public),
            heroTag: 'addGlobalProgramBtn',
            backgroundColor: Colors.purple,
          ),
          FloatingActionButton.extended(
            onPressed: () => _showBroadcastDialog(context),
            label: const Text('Broadcast'),
            icon: const Icon(Icons.chat),
            heroTag: 'sendWhatsAppBtn',
          ),
          FloatingActionButton.extended(
            onPressed: () => AuthService().signOut(),
            label: const Text('Logout'),
            icon: const Icon(Icons.logout),
            backgroundColor: Colors.red.shade400,
            heroTag: 'logoutBtn',
          ),
        ],
      ),
    );
  }
}
