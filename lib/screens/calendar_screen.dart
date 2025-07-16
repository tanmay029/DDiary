import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/diary_entry.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  late final Box<DiaryEntry> _entryBox;
  late final DateTime _joinDate;

  @override
  void initState() {
    super.initState();
    _entryBox = Hive.box<DiaryEntry>('entries');

    // TODO: Replace this with actual stored join date (shared_preferences, Hive, etc.)
    // For demo, fallback to Jan 1st 2024
    _joinDate = DateTime(2024, 1, 1);
  }

  List<DiaryEntry> _getEntriesForDay(DateTime day) {
    return _entryBox.values
        .where((entry) =>
            entry.date.year == day.year &&
            entry.date.month == day.month &&
            entry.date.day == day.day)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: Column(
        children: [
          ValueListenableBuilder(
            valueListenable: _entryBox.listenable(),
            builder: (context, Box<DiaryEntry> box, _) {
              final noteDays = box.values
                  .map((e) =>
                      DateTime(e.date.year, e.date.month, e.date.day))
                  .toSet();

              return TableCalendar(
                firstDay: _joinDate,
                lastDay: DateTime.now(),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                calendarFormat: CalendarFormat.month,
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, events) {
                    final hasNote = noteDays.contains(
                      DateTime(day.year, day.month, day.day),
                    );
                    if (hasNote) {
                      return Positioned(
                        bottom: 1,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _selectedDay == null
                ? const Center(
                    child: Text('Select a date to see entries.'),
                  )
                : ValueListenableBuilder(
                    valueListenable: _entryBox.listenable(),
                    builder: (context, Box<DiaryEntry> box, _) {
                      final entries = _getEntriesForDay(_selectedDay!);
                      if (entries.isEmpty) {
                        return const Center(
                          child: Text('No entries for this day.'),
                        );
                      }
                      return ListView.builder(
                        itemCount: entries.length,
                        itemBuilder: (context, index) {
                          final entry = entries[index];
                          return Card(
                            child: ListTile(
                              title: Text(entry.title),
                              subtitle: Text(entry.content),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
