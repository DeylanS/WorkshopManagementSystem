import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/schedule.dart';
import '../../providers/schedule_provider.dart';
import 'cancel_schedule_page.dart';
import 'edit_schedule_page.dart';

class ManageSchedulePage extends StatelessWidget {
  const ManageSchedulePage({super.key});

  void _confirmDelete(BuildContext context, Schedule schedule) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Cancel Schedule"),
            content: const Text(
              "Are you sure you want to cancel this schedule?",
            ),
            actions: [
              TextButton(
                child: const Text("No"),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
              ElevatedButton(
                child: const Text("Yes, Cancel"),
                onPressed: () {
                  Provider.of<ScheduleProvider>(
                    context,
                    listen: false,
                  ).deleteSchedule(schedule.id);
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheduleProvider = Provider.of<ScheduleProvider>(context);
    final schedules = scheduleProvider.schedules;

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Schedules')),
      body: ListView.builder(
        itemCount: schedules.length,
        itemBuilder: (context, index) {
          final schedule = schedules[index];
          return ListTile(
            title: Text('Foreman ID: ${schedule.foremanId}'),
            subtitle: Text(
              '${schedule.date.toLocal().toString().split(' ')[0]} | ${schedule.startTime} - ${schedule.endTime}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => EditSchedulePage(schedule: schedule),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder:
                          (context) => CancelScheduleDialog(schedule: schedule),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
