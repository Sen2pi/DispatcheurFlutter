import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'note_model.freezed.dart';
part 'note_model.g.dart';

@freezed
@HiveType(typeId: 4)
class NoteModel with _$NoteModel {
  const factory NoteModel({
    @HiveField(0) required String id,
    @HiveField(1) required String content,
    @HiveField(2) required DateTime createdAt,
    @HiveField(3) DateTime? updatedAt,
    @HiveField(4) String? callId,
    @HiveField(5) String? contactId,
    @HiveField(6) @Default([]) List<String> tags,
    @HiveField(7) @Default(false) bool isPinned,
    @HiveField(8) NoteType? type,
    @HiveField(9) Map<String, dynamic>? metadata,
  }) = _NoteModel;

  factory NoteModel.fromJson(Map<String, dynamic> json) =>
      _$NoteModelFromJson(json);
}

@HiveType(typeId: 5)
enum NoteType {
  @HiveField(0)
  general,
  @HiveField(1)
  callNote,
  @HiveField(2)
  reminder,
  @HiveField(3)
  important,
}

extension NoteModelExtensions on NoteModel {
  String get formattedDate {
    final date = updatedAt ?? createdAt;
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  bool get isRecent {
    final now = DateTime.now();
    final date = updatedAt ?? createdAt;
    return now.difference(date).inHours < 24;
  }

  String get preview {
    if (content.length <= 50) return content;
    return '${content.substring(0, 47)}...';
  }
}
