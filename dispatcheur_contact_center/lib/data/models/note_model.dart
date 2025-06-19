import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'note_model.freezed.dart';
part 'note_model.g.dart';

enum NoteType {
  @HiveField(0)
  general,
  @HiveField(1)
  call,
  @HiveField(2)
  meeting,
  @HiveField(3)
  reminder,
}

@freezed
@HiveType(typeId: 1)
class NoteModel with _$NoteModel {
  const factory NoteModel({
    @HiveField(0) required String id,
    @HiveField(1) required String content,
    @HiveField(2) required DateTime createdAt,
    @HiveField(3) DateTime? updatedAt,
    @HiveField(4) @Default(NoteType.general) NoteType type,
    @HiveField(5) String? associatedCallId,
  }) = _NoteModel;

  factory NoteModel.fromJson(Map<String, dynamic> json) =>
      _$NoteModelFromJson(json);
}

extension NoteModelExtension on NoteModel {
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} dia${difference.inDays > 1 ? 's' : ''} atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hora${difference.inHours > 1 ? 's' : ''} atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''} atrás';
    } else {
      return 'Agora mesmo';
    }
  }
}
