import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersAsync = ref.watch(reminderProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Soft background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. User Header & Emergency
              Row(
                children: [
                  // User Avatar
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      'https://i.pravatar.cc/150?u=user',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.person, color: Colors.grey);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Greeting & Name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hai',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Text(
                          'John Doe',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Emergency Button (Pill shaped)
                  FilledButton.icon(
                    onPressed: () => context.push('/emergency-support'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red[50],
                      foregroundColor: Colors.red,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: const StadiumBorder(),
                    ),
                    icon: const Icon(Icons.shield_outlined, size: 18),
                    label: const Text('Emergency'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 2. Next Appointment Section
              const Text(
                'Next Appointment',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Appointment Card
              InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Appointment Details')),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Calendar Icon Container
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.calendar_month,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Dr. Sarah Smith',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Cardiologist',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: Colors.grey[500],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Tomorrow, 10:40 AM',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
              // End Appointment Card
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                height: 200,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => context.push('/scan'),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF1E1E1E),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: const Icon(Icons.camera_alt_outlined),
                            label: const Text('Scan'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () {
                              // Upload logic placeholder
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black87,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: const Icon(Icons.upload_file),
                            label: const Text('Upload'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 3. Previous Prescription Shortcut
              InkWell(
                onTap: () {
                  context.push('/prescription-history');
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.history, color: Colors.black54),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'My previous prescription',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_forward, color: Colors.black54),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // 4. Medicine Today Section
              const Text(
                'Medicine Today',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 180,
                child: remindersAsync.when(
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                  data: (reminders) {
                    if (reminders.isEmpty) {
                      return Center(
                        child: Text(
                          'No medicines today',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      );
                    }
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      itemCount: reminders.length,
                      itemBuilder: (context, index) {
                        final reminder = reminders[index];
                        // Deterministic color based on name hash
                        final color = Colors
                            .primaries[reminder.medicineName.hashCode %
                                Colors.primaries.length]
                            .withValues(alpha: 0.2);

                        return Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: GestureDetector(
                            onTap: () {
                              context.push('/medicine-detail', extra: reminder);
                            },
                            child: _MedicineCard(
                              name: reminder.medicineName,
                              time: DateFormat.jm().format(reminder.time),
                              dosage: reminder.dosage,
                              color: color,
                              isActive:
                                  false, // Reminder logic for "taken" not fully in PillReminder yet
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),

              // 5. Activity Today Section
              const Text(
                'Activity Today',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Column(
                children: [
                  _ActivityCard(label: 'Drink 2L water', isChecked: false),
                  SizedBox(height: 12),
                  _ActivityCard(label: 'Walk 5000 steps', isChecked: false),
                  SizedBox(height: 12),
                  _ActivityCard(label: 'Sleep 8 hours', isChecked: false),
                ],
              ),
              const SizedBox(height: 32), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }
}

class _MedicineCard extends StatelessWidget {
  final String name;
  final String time;
  final String dosage;
  final Color color;
  final bool isActive;

  const _MedicineCard({
    required this.name,
    required this.time,
    required this.dosage,
    required this.color,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              Center(
                child: Icon(
                  Icons.medication_outlined,
                  size: 40,
                  color: Colors.black.withValues(alpha: 0.1),
                ),
              ),
              if (isActive)
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 20,
                      color: Colors.green,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          time,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          dosage,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
          maxLines: 1, // Added maxLines
          overflow: TextOverflow.ellipsis, // Added ellipsis
        ),
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final String label;
  final bool isChecked;

  const _ActivityCard({required this.label, required this.isChecked});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04), // Replaced withOpacity
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey[300]!, width: 2),
              color: isChecked ? Colors.black : Colors.transparent,
            ),
            child:
                isChecked
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
