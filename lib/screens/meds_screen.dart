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
            padding: const EdgeInsets.all(16),
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
                child: Card(
                  elevation: 0,
                  color:
                      reminder.isActive
                          ? Theme.of(context).colorScheme.surfaceContainer
                          : Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.5),
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          reminder.isActive
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.medication,
                        color:
                            reminder.isActive
                                ? Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer
                                : Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    title: Text(
                      reminder.medicineName,
                      style: TextStyle(
                        decoration:
                            reminder.isActive
                                ? null
                                : TextDecoration.lineThrough,
                        color:
                            reminder.isActive
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
                            reminder.isActive
                                ? null
                                : Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                    isThreeLine: true,
                    trailing: Switch(
                      value: reminder.isActive,
                      onChanged: (value) {
                        ref
                            .read(reminderProvider.notifier)
                            .toggleReminder(reminder);
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Push and wait response if needed, but router push is enough as state updates automatically
          context.push('/add-reminder');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
