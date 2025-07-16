import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/diary_entry.dart';
import 'add_edit_entry_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late final Box<DiaryEntry> _entryBox;
  late final DateTime _joinDate;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _entryBox = Hive.box<DiaryEntry>('entries');
    _joinDate = DateTime(2024, 1, 1); // Replace with real join date
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      // Add Entry icon index
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddEditEntryScreen()),
      );
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  List<DiaryEntry> _getEntriesForDay(DateTime day) {
    return _entryBox.values
        .where((entry) =>
            entry.date.year == day.year &&
            entry.date.month == day.month &&
            entry.date.day == day.day)
        .toList();
  }

  Widget _buildHomeContent() {
    return Column(
      children: [
        buildBanner(),
        buildStories(),
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: _entryBox.listenable(),
            builder: (context, Box<DiaryEntry> box, _) {
              if (box.isEmpty) {
                return const Center(child: Text('No entries yet.'));
              }

              final grouped = <String, List<DiaryEntry>>{};
              for (var entry in box.values) {
                String dateKey = entry.date.toLocal().toString().split(' ')[0];
                grouped.putIfAbsent(dateKey, () => []).add(entry);
              }

              final dates = grouped.keys.toList()
                ..sort((a, b) => b.compareTo(a));

              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: dates.length,
                itemBuilder: (context, index) {
                  final date = dates[index];
                  final entries = grouped[date]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          date,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      ...entries.map(
                        (entry) => Card(
                          child: ListTile(
                            title: Text(entry.title),
                            subtitle: Text(
                              '${entry.date.hour.toString().padLeft(2, '0')}:${entry.date.minute.toString().padLeft(2, '0')} - ${entry.content}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Text(entry.mood),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddEditEntryScreen(
                                    entryKey: entry.key,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarContent() {
    return Column(
      children: [
        ValueListenableBuilder(
          valueListenable: _entryBox.listenable(),
          builder: (context, Box<DiaryEntry> box, _) {
            final noteDays = box.values
                .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
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
              ? const Center(child: Text('Select a date to see entries.'))
              : ValueListenableBuilder(
                  valueListenable: _entryBox.listenable(),
                  builder: (context, Box<DiaryEntry> box, _) {
                    final entries = _getEntriesForDay(_selectedDay!);
                    if (entries.isEmpty) {
                      return const Center(
                          child: Text('No entries for this day.'));
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
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return _buildCalendarContent();
      default:
        return const Center(child: Text('Feature coming soon!'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.book),
            SizedBox(width: 8),
            Text('Dear Diary'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
          ),
          const CircleAvatar(child: Text('T')),
          const SizedBox(width: 10),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.blueGrey.shade900,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome_mosaic_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_box),
            label: 'Tasks',
          ),
        ],
      ),
    );
  }

  Widget buildBanner() {
    return Container(
      color: Colors.deepPurple,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Text(
            '🔥 Fire Sale! Membership 37% off',
            style: TextStyle(color: Colors.white),
          ),
          const Spacer(),
          const Text(
            '02:59:41',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget buildStories() {
    final today = DateTime.now();
    final todayDay = today.day;
    final todayMonth = today.month;

    final throwbacks = _entryBox.values.where((entry) =>
        entry.date.day == todayDay &&
        entry.date.month == todayMonth &&
        entry.date.year < today.year);

    DiaryEntry? throwbackEntry;
    if (throwbacks.isNotEmpty) {
      throwbackEntry =
          throwbacks.reduce((a, b) => a.date.isAfter(b.date) ? a : b);
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: Card(
              color: Colors.deepPurple.shade200,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('Today'),
                    Text(
                        '${today.day} ${_monthName(today.month)} ${today.year}'),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Card(
              color: Colors.teal.shade200,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Throwback'),
                    const SizedBox(height: 8),
                    if (throwbackEntry != null)
                      Text(
                        '${throwbackEntry.title}\n${throwbackEntry.content}',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      )
                    else
                      const Text('No throwback today'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month];
  }
}
