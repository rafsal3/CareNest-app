import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/pill_reminder.dart';
import '../services/reminder_service.dart';
import '../services/storage_service.dart';

class MedsScreen extends StatefulWidget {
  const MedsScreen({super.key});

  @override
  State<MedsScreen> createState() => _MedsScreenState();
}

class _MedsScreenState extends State<MedsScreen> {
  List<PillReminder> _reminders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    setState(() => _isLoading = true);
    final reminders = await storageService.getReminders();
    setState(() {
      _reminders = reminders;
      _isLoading = false;
    });
  }

  Future<void> _toggleReminder(PillReminder reminder, bool value) async {
    final updatedReminder = reminder.copyWith(isActive: value);

    // Update local list
    final index = _reminders.indexWhere((r) => r.id == reminder.id);
    if (index != -1) {
      setState(() {
        _reminders[index] = updatedReminder;
      });
    }

    // Update storage
    await storageService.saveReminders(_reminders);

    // Schedule or Cancel notification
    if (value) {
      await reminderService.scheduleReminder(updatedReminder);
    } else {
      await reminderService.cancelReminder(updatedReminder);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Meds')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _reminders.isEmpty
              ? Center(
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
              )
              : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _reminders.length,
                separatorBuilder:
                    (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final reminder = _reminders[index];
                  return Card(
                    elevation: 0,
                    color:
                        reminder.isActive
                            ? Theme.of(context).colorScheme.surfaceContainer
                            : Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                                .withOpacity(0.5),
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
                                  ).colorScheme.onSurface.withOpacity(0.6),
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
                                  ).colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                      isThreeLine: true,
                      trailing: Switch(
                        value: reminder.isActive,
                        onChanged: (value) => _toggleReminder(reminder, value),
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await context.push('/add-reminder');
          if (result == true) {
            _loadReminders();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
