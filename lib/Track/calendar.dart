// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late final ValueNotifier<List<String>> _selectedEvents;
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  Map<DateTime, List<String>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
    _selectedEvents = ValueNotifier([]);
    _loadNotes();

    // Check for today's reminders after the first frame renders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForTodayReminder();
    });
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Calendar with Notes'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2025, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: (day) => _events[DateTime(day.year, day.month, day.day)] ?? [],
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _selectedEvents.value = _events[DateTime(
                    _selectedDay.year,
                    _selectedDay.month,
                    _selectedDay.day,
                  )] ??
                  [];

              // Show notes if there are any for the selected day
              if (_selectedEvents.value.isNotEmpty) {
                _showNotesDialog(_selectedDay, _selectedEvents.value);
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ValueListenableBuilder<List<String>>(
              valueListenable: _selectedEvents,
              builder: (context, events, _) {
                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(events[index]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPlantSelectionDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showPlantSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Plant'),
          content: SingleChildScrollView(
            child: Column(
              children: ['Eggplant', 'Tomato', 'Carrot']
                  .map((plant) => ListTile(
                        title: Text(plant),
                        onTap: () {
                          _addPlantEvents(plant);
                          Navigator.pop(context);
                        },
                      ))
                  .toList(),
            ),
          ),
        );
      },
    );
  }

  void _addPlantEvents(String plant) {
    final plantingDate = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);

    // Predefined plant events
    final Map<String, List<Map<String, dynamic>>> plantEvents = {
      'Eggplant': [
        {'event': 'Water the eggplant', 'daysAfterPlanting': 1},
        {'event': 'Add fertilizer to eggplant', 'daysAfterPlanting': 14},
        {'event': 'Harvest eggplant', 'daysAfterPlanting': 60},
      ],
      'Tomato': [
        {'event': 'Water the tomato', 'daysAfterPlanting': 1},
        {'event': 'Add fertilizer to tomato', 'daysAfterPlanting': 10},
        {'event': 'Harvest tomato', 'daysAfterPlanting': 70},
      ],
      'Carrot': [
        {'event': 'Water the carrot', 'daysAfterPlanting': 1},
        {'event': 'Thin carrot seedlings', 'daysAfterPlanting': 21},
        {'event': 'Harvest carrot', 'daysAfterPlanting': 75},
      ],
    };

    if (plantEvents.containsKey(plant)) {
      for (var task in plantEvents[plant]!) {
        final eventDate = plantingDate.add(Duration(days: task['daysAfterPlanting']));
        final normalizedDate = DateTime(eventDate.year, eventDate.month, eventDate.day);
        if (_events[normalizedDate] == null) {
          _events[normalizedDate] = [];
        }
        _events[normalizedDate]!.add(task['event']);
      }

      // Update selected events and save notes
      _selectedEvents.value = _events[plantingDate] ?? [];
      _saveNotes();
      setState(() {});
    }
  }

  Future<void> _saveNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> encodedEvents = {
      for (var entry in _events.entries)
        entry.key.toIso8601String(): entry.value
    };
    await prefs.setString('plant_events', jsonEncode(encodedEvents));
  }

  void _loadNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? savedData = prefs.getString('plant_events');
    if (savedData != null) {
      final Map<String, dynamic> decodedEvents = Map<String, dynamic>.from(jsonDecode(savedData));
      final Map<DateTime, List<String>> loadedEvents = {};
      for (var entry in decodedEvents.entries) {
        final DateTime date = DateTime.parse(entry.key);
        final List<String> events = List<String>.from(entry.value);
        loadedEvents[date] = events;
      }
      setState(() {
        _events = loadedEvents;
        _selectedEvents.value = _events[_selectedDay] ?? [];
      });
    }
  }

  void _showNotesDialog(DateTime date, List<String> notes) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Notes for ${DateFormat.yMMMd().format(date)}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: notes.map((note) => Text('- $note')).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _checkForTodayReminder() {
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    if (_events[normalizedToday]?.isNotEmpty ?? false) {
      _showNotesDialog(normalizedToday, _events[normalizedToday]!);
    }
  }
}
