import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/schedule.dart';
import '../../providers/schedule_provider.dart';

class CancelScheduleDialog extends StatelessWidget {
  final Schedule schedule;
  const CancelScheduleDialog({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Cancel Schedule"),
      content: const Text("Are you sure you want to cancel this schedule?"),
      actions: [
        TextButton(
          child: const Text("No"),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: const Text("Yes, Cancel"),
          onPressed: () {
            Provider.of<ScheduleProvider>(context, listen: false)
                .deleteSchedule(schedule.id);
            Navigator.of(context).pop(); // Close dialog
          },
        ),
      ],
    );
  }
}
