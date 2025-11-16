import 'package:empower_ananya/models/program_model.dart';
import 'package:empower_ananya/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class AddGlobalProgramScreen extends StatefulWidget {
  const AddGlobalProgramScreen({super.key});

  @override
  State<AddGlobalProgramScreen> createState() => _AddGlobalProgramScreenState();
}

class _AddGlobalProgramScreenState extends State<AddGlobalProgramScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _dateController = TextEditingController();

  String _title = '';
  ProgramType _programType = ProgramType.course;
  DateTime? _selectedDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat.yMMMMd().format(_selectedDate!);
      });
    }
  }

  Future<void> _launchEmailBroadcast(
      Program program, List<String> emails) async {
    final String subject = 'New Program Announcement: ${program.title}';
    final String body = '''
      Hello Scholars,

      We are excited to announce a new program for all members of the Empower Ananya Foundation:

      Program: ${program.title}
      Date: ${DateFormat.yMMMMd().format(program.date)}

      Further details will be shared soon.

      Best regards,
      The Empower Ananya Foundation
    ''';

    // Using 'bcc' is crucial so scholars don't see each other's emails.
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      query:
          'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}&bcc=${emails.join(',')}',
    );

    if (!await launchUrl(emailLaunchUri)) {
      debugPrint('Could not launch email broadcast');
    }
  }

  Future<void> _launchWhatsAppBroadcast(Program program) async {
    final String message = '''
      *New Program Announcement*

      Hello Scholars,
      We are excited to announce a new program: *${program.title}* on *${DateFormat.yMMMMd().format(program.date)}*.

      Please save the date!
    ''';
    final Uri whatsappLaunchUri =
        Uri.parse('https://wa.me/?text=${Uri.encodeComponent(message)}');

    if (!await launchUrl(whatsappLaunchUri,
        mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch WhatsApp');
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a date')));
        return;
      }
      setState(() => _isLoading = true);

      final allScholarIds = await _firestoreService.getAllScholarIds();

      final program = Program(
        id: '',
        title: _title,
        type: _programType,
        date: _selectedDate!,
        involvedScholars: allScholarIds,
        isGlobal: true,
      );

      _firestoreService.addUniversalProgram(program).then((_) async {
        if (!mounted) return;

        // --- START OF AUTOMATED WORKFLOW ---
        final allScholarEmails = await _firestoreService.getAllScholarEmails();

        // *** FIX: Added safety check after await ***
        if (!mounted) return;

        if (allScholarEmails.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Program added, but no scholar emails found to notify.')),
          );
          Navigator.pop(context);
          return;
        }

        await _launchEmailBroadcast(program, allScholarEmails);

        // *** FIX: Added safety check after await ***
        if (!mounted) return;

        await showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Next Step'),
            content: const Text(
                'Email draft created with all scholars in BCC. Would you also like to send a broadcast message via WhatsApp?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  if (mounted) Navigator.pop(context);
                },
                child: const Text('No, Finish'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  await _launchWhatsAppBroadcast(program);
                  if (mounted) Navigator.pop(context);
                },
                child: const Text('Yes, Open WhatsApp'),
              ),
            ],
          ),
        );
        // --- END OF AUTOMATED WORKFLOW ---
      }).catchError((error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add program: $error')));
      }).whenComplete(() {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Universal Program')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                    labelText: 'Program Title', border: OutlineInputBorder()),
                validator: (val) =>
                    val!.isEmpty ? 'Please enter a title' : null,
                onChanged: (val) => _title = val,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ProgramType>(
                initialValue: _programType,
                decoration: const InputDecoration(
                    labelText: 'Program Type', border: OutlineInputBorder()),
                items: ProgramType.values
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.name[0].toUpperCase() +
                              type.name.substring(1)),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _programType = value);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Event Date',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (val) =>
                    val!.isEmpty ? 'Please select a date' : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Add & Notify All Scholars'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
