import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/pill_reminder.dart';

class MedicineDetailScreen extends ConsumerStatefulWidget {
  final PillReminder reminder;

  const MedicineDetailScreen({super.key, required this.reminder});

  @override
  ConsumerState<MedicineDetailScreen> createState() =>
      _MedicineDetailScreenState();
}

class _MedicineDetailScreenState extends ConsumerState<MedicineDetailScreen> {
  bool _isCompleted = false;

  @override
  Widget build(BuildContext context) {
    // Generate deterministic color based on medicine name
    final color =
        Colors.primaries[widget.reminder.medicineName.hashCode %
            Colors.primaries.length];

    // Placeholder data - in a real app, these would come from the Medicine model
    const String category = 'Antibiotic';
    const String type = 'Tablets';
    const String purpose =
        'Commonly used to treat bacterial infections such as chest infections (including pneumonia), dental abscesses, and urinary tract infections (UTIs)';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Medicine'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Image Section with pill organizer
                    Container(
                      height: 280,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Stack(
                          children: [
                            // Placeholder for actual medicine image
                            Center(
                              child: Icon(
                                Icons.medication_rounded,
                                size: 120,
                                color: color.withValues(alpha: 0.3),
                              ),
                            ),
                            // You can replace this with an actual image:
                            // Image.asset('assets/images/pill_organizer.png', fit: BoxFit.cover)
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Medicine Name
                    Text(
                      widget.reminder.medicineName,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tags (Category & Type)
                    Row(
                      children: [
                        _TagChip(
                          icon: Icons.medical_services_outlined,
                          label: category,
                          backgroundColor: Colors.grey[200]!,
                        ),
                        const SizedBox(width: 12),
                        _TagChip(
                          icon: Icons.medication_outlined,
                          label: type,
                          backgroundColor: Colors.grey[200]!,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Purpose Section
                    const Text(
                      'Purpose',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      purpose,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[600],
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Info Row (Frequency & Time)
                    Row(
                      children: [
                        Expanded(
                          child: _InfoCard(
                            label: 'Frequency',
                            value: widget.reminder.frequency,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _InfoCard(
                            label: 'Time',
                            value: DateFormat.jm().format(widget.reminder.time),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Action Button
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed:
                      _isCompleted
                          ? null
                          : () {
                            setState(() {
                              _isCompleted = true;
                            });

                            // Show success feedback
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        '${widget.reminder.medicineName} marked as completed!',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );

                            // Navigate back after a short delay
                            Future.delayed(
                              const Duration(milliseconds: 800),
                              () {
                                if (context.mounted) {
                                  context.pop();
                                }
                              },
                            );
                          },
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        _isCompleted ? Colors.green : Colors.grey[800],
                    disabledBackgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isCompleted ? 'Completed' : 'Mark as Completed',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (_isCompleted) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.check, color: Colors.white, size: 20),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;

  const _TagChip({
    required this.icon,
    required this.label,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.black87),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;

  const _InfoCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
