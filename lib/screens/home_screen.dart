import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/activity.dart';
import '../providers/providers.dart';
import '../widgets/medicine_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final Set<String> _takenMedicineIds = {};

  void _toggleMedicineTaken(String id) {
    setState(() {
      if (_takenMedicineIds.contains(id)) {
        _takenMedicineIds.remove(id);
      } else {
        _takenMedicineIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  // User Avatar & Logout
                  PopupMenuButton<String>(
                    offset: const Offset(0, 50),
                    tooltip: 'Account',
                    onSelected: (value) async {
                      if (value == 'logout') {
                        await ref.read(authProvider.notifier).logout();
                        // Router handles redirection
                      }
                    },
                    itemBuilder:
                        (context) => [
                          const PopupMenuItem(
                            enabled: false,
                            child: Text(
                              'Account',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const PopupMenuDivider(),
                          const PopupMenuItem(
                            value: 'logout',
                            child: Row(
                              children: [
                                Icon(Icons.logout, color: Colors.red, size: 20),
                                SizedBox(width: 12),
                                Text(
                                  'Logout',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(
                        'https://i.pravatar.cc/150?u=${ref.watch(authProvider).user?.email ?? "user"}',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.person, color: Colors.grey);
                        },
                      ),
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
                        Text(
                          ref.watch(authProvider).user?.name ?? 'Guest',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                  context.push('/appointment-detail');
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
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
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
                        label: const Text('Scan Prescription'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Scan prescription or medicine label',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
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

                        final isTaken = _takenMedicineIds.contains(reminder.id);

                        return Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: _InteractiveScaleButton(
                            onPressed: () {
                              _toggleMedicineTaken(reminder.id);
                            },
                            child: MedicineCard(
                              id: reminder.id,
                              name: reminder.medicineName,
                              time: DateFormat.jm().format(reminder.time),
                              dosage: reminder.dosage,
                              color: color,
                              isTaken: isTaken,
                              // On tap opens detail screen
                              onTap: () {
                                context.push(
                                  '/medicine-detail',
                                  extra: reminder,
                                );
                              },
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
              Consumer(
                builder: (context, ref, child) {
                  final activityAsync = ref.watch(activityProvider);

                  return activityAsync.when(
                    loading:
                        () => const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Text('Error: $err'),
                    data: (activities) {
                      final completedCount =
                          activities.where((a) => a.isCompleted).length;
                      final progress =
                          activities.isEmpty
                              ? 0.0
                              : completedCount / activities.length;

                      return Column(
                        children: [
                          // Progress Bar
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$completedCount / ${activities.length} Completed',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${(progress * 100).toInt()}%',
                                style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.grey[200],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.blueAccent,
                              ),
                              minHeight: 6,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Activity List
                          ...activities.map((activity) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Dismissible(
                                key: Key(activity.id),
                                direction: DismissDirection.startToEnd,
                                background: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.only(left: 20),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.check, color: Colors.white),
                                      SizedBox(width: 8),
                                      Text(
                                        'Complete',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                confirmDismiss: (direction) async {
                                  // Optimistically toggle and return false to keep the item in list
                                  ref
                                      .read(activityProvider.notifier)
                                      .toggleActivity(activity.id);
                                  return false; // Don't actually remove efficiently
                                },
                                child: _ActivityCard(
                                  activity: activity,
                                  onToggle: () {
                                    ref
                                        .read(activityProvider.notifier)
                                        .toggleActivity(activity.id);
                                  },
                                ),
                              ),
                            );
                          }),
                        ],
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 32), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }
}

class _InteractiveScaleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;

  const _InteractiveScaleButton({required this.child, required this.onPressed});

  @override
  State<_InteractiveScaleButton> createState() =>
      _InteractiveScaleButtonState();
}

class _InteractiveScaleButtonState extends State<_InteractiveScaleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder:
            (context, child) =>
                Transform.scale(scale: _scaleAnimation.value, child: child),
        child: widget.child,
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final Activity activity;
  final VoidCallback onToggle;

  const _ActivityCard({required this.activity, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: activity.isCompleted ? 0.6 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            color: activity.isCompleted ? Colors.grey[50] : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: activity.isCompleted ? 0.01 : 0.04,
                ),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      activity.isCompleted ? Colors.grey[200] : Colors.blue[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  activity.icon,
                  size: 20,
                  color: activity.isCompleted ? Colors.grey : Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              // Text
              Expanded(
                child: Text(
                  activity.label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    decoration:
                        activity.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                    decorationColor: Colors.grey,
                    color:
                        activity.isCompleted
                            ? Colors.grey[600]
                            : Colors.black87,
                  ),
                ),
              ),
              // Checkbox
              AnimatedScale(
                scale: activity.isCompleted ? 1.0 : 1.0,
                // A subtle bounce could be done with a Stateful widget but simple scale can work if we toggle values.
                // Assuming simple transition for now as requested.
                duration: const Duration(milliseconds: 200),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          activity.isCompleted
                              ? Colors.green
                              : Colors.grey[300]!,
                      width: 2,
                    ),
                    color:
                        activity.isCompleted
                            ? Colors.green
                            : Colors.transparent,
                  ),
                  child:
                      activity.isCompleted
                          ? const Center(
                            child: Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            ),
                          )
                          : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
