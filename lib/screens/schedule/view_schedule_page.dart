import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/schedule.dart';
import '../../providers/schedule_provider.dart';
import 'add_schedule_page.dart';
import 'edit_schedule_page.dart';
import 'cancel_schedule_page.dart';
import 'manage_schedule_page.dart';
import 'schedule_dashboard.dart';

class ViewSchedulePage extends StatelessWidget {
  const ViewSchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheduleProvider = Provider.of<ScheduleProvider>(context);
    final schedules = scheduleProvider.schedules;

    return Scaffold(
      appBar: AppBar(
        title: const Text('View Schedules'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ScheduleDashboard(),
                ),
              );
            },
          ),
        ],
      ),
      body:
          schedules.isEmpty
              ? const Center(child: Text("No schedules available."))
              : ListView.builder(
                itemCount: schedules.length,
                itemBuilder: (context, index) {
                  final schedule = schedules[index];
                  return ListTile(
                    title: Text('Foreman ID: ${schedule.foremanId}'),
                    subtitle: Text(
                      '${schedule.date.toLocal().toString().split(' ')[0]} | ${schedule.startTime} - ${schedule.endTime}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.manage_accounts,
                        color: Colors.green,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ManageSchedulePage(),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddSchedulePage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
