import 'package:flutter/material.dart';

class MoodPicker extends StatelessWidget {
  final String selectedMood;
  final Function(String) onMoodSelected;

  const MoodPicker({
    super.key,
    required this.selectedMood,
    required this.onMoodSelected,
  });

  final moods = const ['😊', '😢', '😡', '😍', '😴'];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      children: moods.map((mood) {
        return GestureDetector(
          onTap: () => onMoodSelected(mood),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: selectedMood == mood
                  ? Colors.blueAccent
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              mood,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        );
      }).toList(),
    );
  }
}
