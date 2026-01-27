import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/pill_reminder.dart';

class MedicineDetailScreen extends StatelessWidget {
  final PillReminder reminder;

  const MedicineDetailScreen({super.key, required this.reminder});

  @override
  Widget build(BuildContext context) {
    // Generate deterministic color and placeholder data
    final color =
        Colors.primaries[reminder.medicineName.hashCode %
            Colors.primaries.length];

    // Placeholder data since PillReminder doesn't have these yet
    // In a real app, these would come from the DB/API
    const String category = 'Antibiotic'; // Placeholder
    const String type = 'Tablets'; // Placeholder
    const String purpose =
        'Used for treating bacterial infections. Take the full course as prescribed by your doctor to ensure effectiveness.';

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
          fontWeight: FontWeight.bold,
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
                    // Hero Image Section
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(24),
                        // In reality, this would be an image asset or network image
                        // Using Icon for now as placeholder matching the visual request
                      ),
                      child: Center(
                        child: Icon(Icons.medication, size: 80, color: color),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Medicine Info Section
                    Text(
                      reminder.medicineName,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Tags
                    Row(
                      children: [
                        _TagChip(label: category, color: Colors.purple.shade50),
                        const SizedBox(width: 12),
                        _TagChip(label: type, color: Colors.orange.shade50),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Purpose Section
                    const Text(
                      'Purpose',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      purpose,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Info Row (Frequency & Time)
                    Row(
                      children: [
                        Expanded(
                          child: _InfoItem(
                            label: 'Frequency',
                            value: reminder.frequency,
                            icon: Icons.repeat,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _InfoItem(
                            label: 'Time',
                            value: DateFormat.jm().format(reminder.time),
                            icon: Icons.access_time,
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
                  onPressed: () {
                    // Action logic
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${reminder.medicineName} marked as completed!',
                        ),
                      ),
                    );
                    context.pop();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: const StadiumBorder(),
                  ),
                  child: const Text(
                    'Mark as Completed',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
  final String label;
  final Color color;

  const _TagChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: Colors.grey[700]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
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
