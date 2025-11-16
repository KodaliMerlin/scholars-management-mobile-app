import 'package:empower_ananya/models/college_model.dart';
import 'package:empower_ananya/models/program_model.dart';
import 'package:empower_ananya/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddEventScreen extends StatefulWidget {
  // Updated to accept the entire 'college' object
  final College college;
  const AddEventScreen({super.key, required this.college});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
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

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a date')),
        );
        return;
      }
      setState(() => _isLoading = true);

      // New logic: Get scholar IDs for the specific college name
      final scholarIds =
          await _firestoreService.getScholarIdsForCollege(widget.college.name);

      final program = Program(
        id: '', // Firestore will generate this
        title: _title,
        type: _programType,
        date: _selectedDate!,
        involvedScholars: scholarIds, // Assign the fetched scholars
        isGlobal: false,
      );

      _firestoreService
          .addProgram(widget.college.id, program.toFirestore())
          .then((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Program added for ${scholarIds.length} scholars!')),
        );
        Navigator.pop(context);
      }).catchError((error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add event: $error')),
        );
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
      appBar: AppBar(
        title: const Text('Add New Program'),
      ),
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
                  if (value != null) {
                    setState(() {
                      _programType = value;
                    });
                  }
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
                        child: const Text('Add Program'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
