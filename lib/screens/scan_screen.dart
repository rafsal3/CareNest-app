import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/medicine_draft.dart';
import '../models/pill_reminder.dart';
import '../providers/providers.dart';
import '../services/prescription_ai_service.dart';
import '../utils/image_helper.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;
  final PrescriptionAiService _aiService = PrescriptionAiService();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        // Safe resizing/compression
        final File? safeFile = await ImageHelper.compressImage(
          File(pickedFile.path),
        );

        if (safeFile == null) {
          throw Exception("Failed to process image. Please try another.");
        }

        setState(() {
          _image = safeFile;
        });
        _analyzeImage(); // Auto-upload on selection
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _analyzeImage() async {
    if (_image == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final results = await _aiService.analyzePrescription(_image!);

      if (!mounted) return;

      setState(() {
        _isProcessing = false;
      });

      if (results.isNotEmpty) {
        _showConfirmationSheet(results);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No medicines found in the image.')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            action: SnackBarAction(label: 'Retry', onPressed: _analyzeImage),
          ),
        );
      }
    }
  }

  void _clearSelection() {
    setState(() {
      _image = null;
    });
  }

  void _showConfirmationSheet(List<MedicineDraft> drafts) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (sheetContext) => _ConfirmationSheet(
            drafts: drafts,
            onComplete: () {
              Navigator.pop(sheetContext);
              // Optionally refresh or navigate
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Prescription'),
        actions: [
          if (_image != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _clearSelection,
              tooltip: 'Clear',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Preview Area
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child:
                  _image != null
                      ? Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(_image!, fit: BoxFit.cover),
                          if (_isProcessing)
                            Container(
                              color: Colors.black45,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'AI is reading prescription...',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      )
                      : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.document_scanner_outlined,
                            size: 64,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Take a photo of the prescription',
                            style: TextStyle(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            if (_image == null)
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _ConfirmationSheet extends ConsumerStatefulWidget {
  final List<MedicineDraft> drafts;
  final VoidCallback onComplete;

  const _ConfirmationSheet({required this.drafts, required this.onComplete});

  @override
  ConsumerState<_ConfirmationSheet> createState() => _ConfirmationSheetState();
}

class _ConfirmationSheetState extends ConsumerState<_ConfirmationSheet> {
  final Set<int> _savedIndices = {};
  bool _isSaving = false;

  Future<void> _saveAllMedicines() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final medicineService = ref.read(medicineServiceProvider);
      final medicinesNotifier = ref.read(medicinesProvider.notifier);
      final reminderNotifier = ref.read(reminderProvider.notifier);

      for (int i = 0; i < widget.drafts.length; i++) {
        if (_savedIndices.contains(i)) continue; // Skip already saved

        final draft = widget.drafts[i];

        // 1. Create Medicine
        final medicine = await medicineService.createMedicine(
          draft.name ?? 'Unknown Medicine',
          draft.dosage ?? 'As prescribed',
        );

        // 2. Add to medicines list
        await medicinesNotifier.addMedicine(medicine);

        // 3. Generate schedule times if not present
        List<DateTime> scheduleTimes = draft.scheduleTimes;
        if (scheduleTimes.isEmpty && draft.frequencyPerDay != null) {
          scheduleTimes = _generateDefaultTimes(draft.frequencyPerDay!);
        }

        // 4. Create reminders
        if (scheduleTimes.isNotEmpty) {
          for (final time in scheduleTimes) {
            final reminder = PillReminder(
              id:
                  DateTime.now().millisecondsSinceEpoch.toString() +
                  time.millisecondsSinceEpoch.toString() +
                  i.toString(),
              medicineName: medicine.name,
              dosage: medicine.type,
              frequency:
                  '${draft.frequencyPerDay ?? scheduleTimes.length}x daily',
              time: time,
              isActive: true,
            );
            await reminderNotifier.addReminder(reminder);
          }
        }

        _savedIndices.add(i);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Saved ${widget.drafts.length} medicine(s) successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        widget.onComplete();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving medicines: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  List<DateTime> _generateDefaultTimes(int frequency) {
    if (frequency <= 0) return [];

    final now = DateTime.now();
    final times = <DateTime>[];

    if (frequency == 1) {
      times.add(DateTime(now.year, now.month, now.day, 9, 0));
    } else if (frequency == 2) {
      times.add(DateTime(now.year, now.month, now.day, 9, 0));
      times.add(DateTime(now.year, now.month, now.day, 21, 0));
    } else if (frequency == 3) {
      times.add(DateTime(now.year, now.month, now.day, 9, 0));
      times.add(DateTime(now.year, now.month, now.day, 14, 0));
      times.add(DateTime(now.year, now.month, now.day, 21, 0));
    } else {
      times.add(DateTime(now.year, now.month, now.day, 8, 0));
      times.add(DateTime(now.year, now.month, now.day, 12, 0));
      times.add(DateTime(now.year, now.month, now.day, 16, 0));
      times.add(DateTime(now.year, now.month, now.day, 20, 0));
    }
    return times;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder:
          (context, scrollController) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Confirm Medicines',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (_savedIndices.isNotEmpty)
                          Text(
                            '${_savedIndices.length}/${widget.drafts.length} saved',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _isSaving ? null : widget.onComplete,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  itemCount: widget.drafts.length,
                  separatorBuilder:
                      (context, index) => const SizedBox(height: 24),
                  itemBuilder: (context, index) {
                    final draft = widget.drafts[index];
                    final isSaved = _savedIndices.contains(index);

                    return _DraftMedicineCard(draft: draft, isSaved: isSaved);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSaving ? null : widget.onComplete,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton(
                        onPressed: _isSaving ? null : _saveAllMedicines,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child:
                            _isSaving
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : const Text('Save All'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
    );
  }
}

class _DraftMedicineCard extends StatelessWidget {
  final MedicineDraft draft;
  final bool isSaved;

  const _DraftMedicineCard({required this.draft, this.isSaved = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.medication, color: Colors.blue[700]),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      draft.name ?? 'Unknown Medicine',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      draft.dosage ?? '',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _InfoItem(
                label: 'Frequency',
                value: '${draft.frequencyPerDay ?? 1}x daily',
              ),
              _InfoItem(
                label: 'Duration',
                value: '${draft.durationDays ?? 1} days',
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Scheduled Times:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                draft.scheduleTimes.map((time) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      DateFormat.jm().format(time),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
          ),
          const SizedBox(height: 16),
          if (isSaved)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[300]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.green[700], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Saved',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pending, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Will be saved',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  const _InfoItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
