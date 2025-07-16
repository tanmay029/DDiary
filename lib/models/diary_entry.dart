import 'package:hive/hive.dart';

part 'diary_entry.g.dart';

@HiveType(typeId: 0)
class DiaryEntry extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String content;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  String mood;

  @HiveField(4)
  String? imagePath; // ✅ Add this

  DiaryEntry({
    required this.title,
    required this.content,
    required this.date,
    this.mood = '',
    this.imagePath, // ✅ Add this
  });
}
