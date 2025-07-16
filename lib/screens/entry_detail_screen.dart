import 'dart:io';

import 'package:flutter/material.dart';

import '../models/diary_entry.dart';
import 'add_edit_entry_screen.dart';

class EntryDetailScreen extends StatelessWidget {
  final DiaryEntry entry;

  const EntryDetailScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(entry.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditEntryScreen(entryKey: entry.key),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              entry.delete();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.date.toLocal().toString().split(' ')[0],
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Text(
              entry.content,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Text('Mood: ${entry.mood}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            entry.imagePath != null
                ? Image.file(File(entry.imagePath!))
                : Container(),
          ],
        ),
      ),
    );
  }
}
