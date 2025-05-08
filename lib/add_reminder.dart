import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:greengath/noti_service.dart';
import 'package:greengath/reminder_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'reminder_model.dart';

class AddReminderPage extends StatefulWidget {
  const AddReminderPage({super.key});

  @override
  State<AddReminderPage> createState() => _AddReminderPageState();
}

class _AddReminderPageState extends State<AddReminderPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isDaily = false;
  final List<bool> _selectedDays = List.filled(7, false); // One entry for each day of the week

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

    Future<void> saveReminder(Reminder reminder) async {
    final prefs = await SharedPreferences.getInstance();
    final remindersJson = prefs.getStringList('reminders') ?? [];

    final reminderMap = jsonEncode(reminder.toMap());
    remindersJson.add(reminderMap);

    await prefs.setStringList('reminders', remindersJson);
    print(reminder.time.hour);
    NotiService().scheduleNotification(
      id: reminder.id,
      title: "Green Path",
      body: "Don't forget to water your ${reminder.title}",
      hour: reminder.time.hour,
      minute: reminder.time.minute,
      isDaily: reminder.isDaily,
      repeatDays: reminder.repeatDays,
      );
  }

  // Get selected days based on user's input
  List<int> _getSelectedDays() {
    List<int> days = [];
    for (int i = 0; i < _selectedDays.length; i++) {
      if (_selectedDays[i]) days.add(i + 1); // 1=Monday, ..., 7=Sunday
    }
    return days;
  }

  bool _isSaving = false;

  void _saveReminder() {
    if (_isSaving) return;

    if (_formKey.currentState!.validate()) {
      _isSaving = true;

      final reminder = Reminder(
        id: DateTime.now().millisecondsSinceEpoch % (2^31 - 1),
        title: _titleController.text,
        time: _selectedTime,
        isDaily: _isDaily,
        repeatDays: _isDaily ? [] : _getSelectedDays(),
      );

      // Close the keyboard
      FocusScope.of(context).unfocus();

      // Schedule navigation after current frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          saveReminder(reminder);
          // Navigator.of(context).pop(reminder); // Sends reminder back to the previous screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ReminderListPage()),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Reminder"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _selectTime(context),
                child: Text(
                  'Select Time: ${_selectedTime.format(context)}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),
              SwitchListTile(
                title: const Text('Daily'),
                value: _isDaily,
                onChanged: (value) {
                  setState(() {
                    _isDaily = value;
                  });
                },
              ),
              if (!_isDaily) ...[
                const SizedBox(height: 10),
                const Text('Repeat on:'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: List.generate(7, (index) {
                    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                    return FilterChip(
                      label: Text(dayNames[index]),
                      selected: _selectedDays[index],
                      onSelected: (selected) {
                        setState(() {
                          _selectedDays[index] = selected;
                        });
                      },
                    );
                  }),
                ),
              ],
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveReminder,
                  child: const Text('Save Reminder'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
