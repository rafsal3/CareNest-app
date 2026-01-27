import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/pill_reminder.dart';
import '../providers/providers.dart';

class AddReminderScreen extends ConsumerStatefulWidget {
  const AddReminderScreen({super.key});

  @override
  ConsumerState<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends ConsumerState<AddReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  String _frequency = 'Once daily';
  TimeOfDay _time = const TimeOfDay(hour: 8, minute: 0);

  final List<String> _frequencyOptions = [
    'Once daily',
    'Twice daily',
    'Three times daily',
    'As needed',
  ];

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked != null && picked != _time) {
      setState(() {
        _time = picked;
      });
    }
  }

  Future<void> _saveReminder() async {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final reminderTime = DateTime(
        now.year,
        now.month,
        now.day,
        _time.hour,
        _time.minute,
      );

      final newReminder = PillReminder(
        id: const Uuid().v4(),
        medicineName: _nameController.text,
        dosage: _dosageController.text,
        frequency: _frequency,
        time: reminderTime,
        isActive: true,
      );

      // Save using Riverpod provider
      await ref.read(reminderProvider.notifier).addReminder(newReminder);

      if (mounted) {
        context.pop(true); // Return true to indicate refresh needed
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Reminder')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Medicine Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter medicine name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dosageController,
                decoration: const InputDecoration(
                  labelText: 'Dosage (e.g. 500mg)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter dosage';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _frequency,
                decoration: const InputDecoration(
                  labelText: 'Frequency',
                  border: OutlineInputBorder(),
                ),
                items:
                    _frequencyOptions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _frequency = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectTime(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Reminder Time',
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _time.format(context),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const Icon(Icons.access_time),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saveReminder,
                  child: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      'Save Reminder',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
