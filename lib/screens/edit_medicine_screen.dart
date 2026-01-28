import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/medicine_draft.dart';
import '../models/medicine.dart';
import '../models/pill_reminder.dart';
import '../providers/providers.dart';

class EditMedicineScreen extends ConsumerStatefulWidget {
  final Medicine? medicine;
  final MedicineDraft? draft;
  final bool isNew;

  const EditMedicineScreen({
    super.key,
    this.medicine,
    this.draft,
    this.isNew = false,
  });

  @override
  ConsumerState<EditMedicineScreen> createState() => _EditMedicineScreenState();
}

class _EditMedicineScreenState extends ConsumerState<EditMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _dosageController;
  late TextEditingController _frequencyController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill data
    final name = widget.medicine?.name ?? widget.draft?.name ?? '';
    final dosage = widget.medicine?.type ?? widget.draft?.dosage ?? '';
    // Note: Medicine model 'type' is often used as dosage/type in placeholder,
    // but ideally we should have a dosage field in Medicine model too.
    // For now, mapping 'type' to dosage/type input.

    final frequency = widget.draft?.frequencyPerDay?.toString() ?? '1';

    _nameController = TextEditingController(text: name);
    _dosageController = TextEditingController(text: dosage);
    _frequencyController = TextEditingController(text: frequency);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final name = _nameController.text;
      final type =
          _dosageController.text; // Treating type as dosage/form factor

      Medicine savedMedicine;

      if (widget.isNew) {
        // Create New
        savedMedicine = await ref
            .read(medicineServiceProvider)
            .createMedicine(name, type);

        // 1. Add to Medicines List (Local)
        await ref.read(medicinesProvider.notifier).addMedicine(savedMedicine);

        // 2. Add Reminders (Local)
        List<DateTime> scheduleTimes = [];
        if (widget.draft != null && widget.draft!.scheduleTimes.isNotEmpty) {
          scheduleTimes = widget.draft!.scheduleTimes;
        } else {
          // If no draft times, generate based on frequency input
          final freq = int.tryParse(_frequencyController.text) ?? 1;
          scheduleTimes = _generateDefaultTimes(freq);
        }

        if (scheduleTimes.isNotEmpty) {
          final freqText =
              _frequencyController.text.isNotEmpty
                  ? '${_frequencyController.text}x daily'
                  : '${scheduleTimes.length}x daily';

          for (final time in scheduleTimes) {
            final reminder = PillReminder(
              id:
                  DateTime.now().millisecondsSinceEpoch.toString() +
                  time.millisecondsSinceEpoch.toString(),
              medicineName: savedMedicine.name,
              dosage: savedMedicine.type,
              frequency: freqText,
              time: time,
              isActive: true,
            );
            await ref.read(reminderProvider.notifier).addReminder(reminder);
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Medicine and reminders created locally'),
            ),
          );
          context.pop(true); // Return success
        }
      } else {
        // Update Existing
        if (widget.medicine != null) {
          savedMedicine = await ref
              .read(medicineServiceProvider)
              .updateMedicine(widget.medicine!.id, {
                'name': name,
                'medicineType': type,
              });

          await ref
              .read(medicinesProvider.notifier)
              .updateMedicineLocally(savedMedicine);

          // Note: Updating existing medicine reminders is not yet implemented
          // fully as it requires searching reminders by name.

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Medicine saved locally')),
            );
            context.pop(true);
          }
        }
      }

      // No need to refresh providers as we updated them directly via notifiers
      // ref.refresh(medicinesProvider);
      // ref.refresh(reminderProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<DateTime> _generateDefaultTimes(int frequency) {
    if (frequency <= 0) return [];

    // Simple logic to spread times across the day (9am to 9pm)
    final now = DateTime.now();
    final times = <DateTime>[];

    if (frequency == 1) {
      times.add(DateTime(now.year, now.month, now.day, 9, 0)); // 9 AM
    } else if (frequency == 2) {
      times.add(DateTime(now.year, now.month, now.day, 9, 0)); // 9 AM
      times.add(DateTime(now.year, now.month, now.day, 21, 0)); // 9 PM
    } else if (frequency == 3) {
      times.add(DateTime(now.year, now.month, now.day, 9, 0)); // 9 AM
      times.add(DateTime(now.year, now.month, now.day, 14, 0)); // 2 PM
      times.add(DateTime(now.year, now.month, now.day, 21, 0)); // 9 PM
    } else {
      // For 4+, just spread them out every (12 / (n-1)) hours starting 8am?
      // Simplified: Just add some defaults or cap at 4 for now.
      times.add(DateTime(now.year, now.month, now.day, 8, 0));
      times.add(DateTime(now.year, now.month, now.day, 12, 0));
      times.add(DateTime(now.year, now.month, now.day, 16, 0));
      times.add(DateTime(now.year, now.month, now.day, 20, 0));
    }
    return times;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNew ? 'Add Medicine' : 'Edit Medicine'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Medicine Name',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dosageController,
                decoration: const InputDecoration(
                  labelText: 'Dosage / Type (e.g. 500mg or Tablet)',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              // Frequency (Only mainly relevant if we are setting up reminders, keeping simple for now)
              if (widget.isNew) ...[
                TextFormField(
                  controller: _frequencyController,
                  decoration: const InputDecoration(
                    labelText: 'Times per Day',
                    border: OutlineInputBorder(),
                    helperText: 'Used to schedule reminders automatically',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
              ],

              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isLoading ? null : _save,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text('Save Medicine'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
