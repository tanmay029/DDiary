import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/diary_entry.dart';

class AddEditEntryScreen extends StatefulWidget {
  final int? entryKey;

  const AddEditEntryScreen({super.key, this.entryKey});

  @override
  State<AddEditEntryScreen> createState() => _AddEditEntryScreenState();
}

class _AddEditEntryScreenState extends State<AddEditEntryScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  DiaryEntry? _entry;

  @override
  void initState() {
    super.initState();
    if (widget.entryKey != null) {
      final box = Hive.box<DiaryEntry>('entries');
      _entry = box.get(widget.entryKey);
      _titleController.text = _entry?.title ?? '';
      _contentController.text = _entry?.content ?? '';
    }
  }

  void _save() async {
    final box = Hive.box<DiaryEntry>('entries');
    if (widget.entryKey != null && _entry != null) {
      _entry!
        ..title = _titleController.text
        ..content = _contentController.text
        ..date = DateTime.now();
      _entry!.save();
    } else {
      final newEntry = DiaryEntry(
        title: _titleController.text,
        content: _contentController.text,
        date: DateTime.now(),
      );
      await box.add(newEntry);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entryKey != null ? 'Edit Entry' : 'New Entry'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _save,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                decoration: const InputDecoration(labelText: 'Content'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
