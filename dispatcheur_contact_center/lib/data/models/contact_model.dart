import 'package:freezed_annotation/freezed_annotation.dart';

part 'contact_model.freezed.dart';
part 'contact_model.g.dart';

@freezed
class ContactModel with _$ContactModel {
  const factory ContactModel({
    required String id,
    required String name,
    String? mobile,
    String? landline,
    String? email,
    @Default(false) bool personal,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ContactModel;

  factory ContactModel.fromJson(Map<String, dynamic> json) =>
      _$ContactModelFromJson(json);
}

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
