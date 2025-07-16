import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/diary_entry.dart';
import 'add_edit_entry_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<DiaryEntry> _results = [];

  void _search(String query) {
    final box = Hive.box<DiaryEntry>('entries');
    final allEntries = box.values.toList();

    final results = allEntries.where((entry) {
      final titleMatch = entry.title.toLowerCase().contains(query.toLowerCase());
      final contentMatch = entry.content.toLowerCase().contains(query.toLowerCase());
      return titleMatch || contentMatch;
    }).toList();

    setState(() {
      _results = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          decoration: const InputDecoration(
            hintText: 'Search notes...',
            border: InputBorder.none,
          ),
          onChanged: _search,
          autofocus: true,
        ),
      ),
      body: _results.isEmpty
          ? const Center(child: Text('No results'))
          : ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final entry = _results[index];
                return Card(
                  child: ListTile(
                    title: Text(entry.title),
                    subtitle: Text(
                      '${entry.date} • ${entry.content}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddEditEntryScreen(entryKey: entry.key),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
