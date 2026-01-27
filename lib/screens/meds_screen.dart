import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/providers.dart';

class MedsScreen extends ConsumerWidget {
  const MedsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersState = ref.watch(reminderProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Meds')),
      body: remindersState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (reminders) {
          if (reminders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medication_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No reminders yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add a reminder',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
            itemCount: reminders.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final reminder = reminders[index];
              return Dismissible(
                key: Key(reminder.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  ref.read(reminderProvider.notifier).removeReminder(reminder);
                },
                child: _AnimatedMedicineCard(
                  reminder: reminder,
                  onTap: () {
                    context.push('/medicine-detail', extra: reminder);
                  },
                  onToggle: (value) {
                    ref
                        .read(reminderProvider.notifier)
                        .toggleReminder(reminder);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: FloatingActionButton(
          onPressed: () {
            context.push('/add-reminder');
          },
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _AnimatedMedicineCard extends StatefulWidget {
  final dynamic
  reminder; // Using dynamic or PillReminder if available. Since this file imports providers, we might not have the model directly imported unless it's exported.
  // Actually, 'reminders' in data is List<PillReminder>.
  // I should check imports. providers.dart usually exports models.
  // The file imports '../providers/providers.dart'. Let's assume PillReminder is available or I can use dynamic to be safe, but strong typing is better.
  // Step 460 shows 'import '../providers/providers.dart';'.
  // I will assume PillReminder is available via providers.dart exports (common pattern) or I might need to import it.
  // Wait, step 14 in file 394 (router.dart) imports 'models/pill_reminder.dart'.
  // Step 460 code didn't import models explicitly, but it worked.
  // Ah, the original code used `reminder` variable but didn't type it in the itemBuilder explicitly?
  // `final reminder = reminders[index];` -> Dart inference.
  // `providers.dart` must allow access to the type.
  // I'll stick to strong typing if I can, but to avoid import errors if `PillReminder` isn't exported by `providers.dart`, I will add the import.
  // Wait, I can't add imports easily with replace_file_content if I only replace the class.
  // I will replace the WHOLE class MedsScreen and add the new class at the bottom.
  // AND I will add the import if needed.
  // Let's assume the previous code worked, so `PillReminder` type is known or inferred.
  // I'll just use `final GlobalKey...` or similar.
  // Actually, I can just use `dynamic` or `var` in the widget if I'm lazy, but `required this.reminder` works if I define the field as `final PillReminder reminder`.
  // If `PillReminder` isn't imported, I'd get an error.
  // The original file imports:
  // import 'package:flutter/material.dart';
  // import 'package:go_router/go_router.dart';
  // import 'package:flutter_riverpod/flutter_riverpod.dart';
  // import 'package:intl/intl.dart';
  // import '../providers/providers.dart';
  // It does NOT import pill_reminder.dart individually.
  // So `providers.dart` likely exports it.

  final Function() onTap;
  final Function(bool) onToggle;

  const _AnimatedMedicineCard({
    required this.reminder,
    required this.onTap,
    required this.onToggle,
  });

  @override
  State<_AnimatedMedicineCard> createState() => _AnimatedMedicineCardState();
}

class _AnimatedMedicineCardState extends State<_AnimatedMedicineCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reminder = widget.reminder;
    final isActive = reminder.isActive;

    // Safety check just in case types are weird, but standard access should work
    // Assuming matching fields from original file: medicineName, dosage, frequency, time, id

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Card(
          elevation: 0,
          color:
              isActive
                  ? Theme.of(context).colorScheme.surfaceContainer
                  : Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          clipBehavior: Clip.antiAlias,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(
              backgroundColor:
                  isActive
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Icon(
                Icons.medication,
                color:
                    isActive
                        ? Theme.of(context).colorScheme.onPrimaryContainer
                        : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            title: Text(
              reminder.medicineName,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                decoration: isActive ? null : TextDecoration.lineThrough,
                color:
                    isActive
                        ? null
                        : Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            subtitle: Text(
              '${reminder.dosage} • ${reminder.frequency}\n${DateFormat.jm().format(reminder.time)}',
              style: TextStyle(
                color:
                    isActive
                        ? null
                        : Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            isThreeLine: true,
            trailing: Switch(value: isActive, onChanged: widget.onToggle),
          ),
        ),
      ),
    );
  }
}
