import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'contact_model.freezed.dart';
part 'contact_model.g.dart';

@freezed
@HiveType(typeId: 0)
class ContactModel with _$ContactModel {
  const factory ContactModel({
    @HiveField(0) required String id,
    @HiveField(1) required String name,
    @HiveField(2) String? mobile,
    @HiveField(3) String? landline,
    @HiveField(4) String? email,
    @HiveField(5) @Default(false) bool personal,
    @HiveField(6) DateTime? createdAt,
    @HiveField(7) DateTime? updatedAt,
  }) = _ContactModel;

  factory ContactModel.fromJson(Map<String, dynamic> json) =>
      _$ContactModelFromJson(json);
}

// Extension para getters customizados
extension ContactModelExtension on ContactModel {
  String get initials {
    final nameParts = name.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts.first[0]}${nameParts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String get displayName => name.isNotEmpty ? name : 'Sem Nome';

  String get primaryPhone => mobile ?? landline ?? '';

  bool get hasPhoneNumber => mobile != null || landline != null;
}
