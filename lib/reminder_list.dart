import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:greengath/add_reminder.dart';
import 'package:greengath/reminder_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReminderListPage extends StatefulWidget {
  const ReminderListPage({Key? key}) : super(key: key);

  @override
  _ReminderListPageState createState() => _ReminderListPageState();
}

class _ReminderListPageState extends State<ReminderListPage> {
  List<Reminder> _reminders = [];

  @override
  void initState() {
    super.initState();
    loadReminders(); // Load saved reminders when the page is initialized
  }

  // Load reminders from SharedPreferences
  Future<void> loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final remindersJson = prefs.getStringList('reminders') ?? [];

    setState(() {
      _reminders = remindersJson
          .map((json) => Reminder.fromMap(jsonDecode(json)))
          .toList();
    });
  }

  Future<void> deleteReminder(int index) async {
  final prefs = await SharedPreferences.getInstance();
  _reminders.removeAt(index);
  final remindersJson = _reminders.map((r) => jsonEncode(r.toMap())).toList();
  await prefs.setStringList('reminders', remindersJson);
  setState(() {});
}
  // Get the repeat days text to display
  String _getFrequencyText(Reminder reminder) {
    if (reminder.isDaily) return 'Daily';
    if (reminder.repeatDays.isEmpty) return 'Once';
    
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return reminder.repeatDays.map((day) => dayNames[day - 1]).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Reminders'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final reminder = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddReminderPage()),
          );
          if (reminder != null) {
            //saveReminder(reminder); // Save the new reminder locally
            loadReminders(); // Reload the list to reflect the new reminder
          }
        },
        child: const Icon(Icons.add),
      ),
      body: _reminders.isEmpty
          ? const Center(
              child: Text('No reminders yet'),
            )
          : ListView.builder(
              itemCount: _reminders.length,
              itemBuilder: (context, index) {
                final reminder = _reminders[index];
               return ListTile(
                title: Text(reminder.title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Time: ${reminder.time.format(context)}'),
                    Text('Repeat: ${_getFrequencyText(reminder)}'),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.grey),
                  onPressed: () => deleteReminder(index),
                ),
              );

              },
            ),
    );
  }
}
