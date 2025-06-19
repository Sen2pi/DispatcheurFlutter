import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'contact_model.freezed.dart';
part 'contact_model.g.dart';

@freezed
@HiveType(typeId: 3)
class ContactModel with _$ContactModel {
  const factory ContactModel({
    @HiveField(0) required String id,
    @HiveField(1) required String name,
    @HiveField(2) String? mobile,
    @HiveField(3) String? landline,
    @HiveField(4) String? email,
    @HiveField(5) String? company,
    @HiveField(6) String? avatar,
    @HiveField(7) @Default(false) bool personal,
    @HiveField(8) @Default(false) bool favorite,
    @HiveField(9) DateTime? lastContact,
    @HiveField(10) @Default([]) List<String> tags,
    @HiveField(11) Map<String, dynamic>? metadata,
    @HiveField(12) DateTime? createdAt,
    @HiveField(13) DateTime? updatedAt,
  }) = _ContactModel;

  factory ContactModel.fromJson(Map<String, dynamic> json) =>
      _$ContactModelFromJson(json);
}

extension ContactModelExtensions on ContactModel {
  String get primaryPhone => mobile ?? landline ?? '';

  String get initials {
    final words = name.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return name.length >= 2
        ? name.substring(0, 2).toUpperCase()
        : name.toUpperCase();
  }

  bool get hasPhoneNumber => mobile != null || landline != null;

  bool get isValid => name.isNotEmpty && hasPhoneNumber;

  String get displayName => name.isEmpty ? 'Contato sem nome' : name;

  List<String> get phoneNumbers {
    final phones = <String>[];
    if (mobile != null && mobile!.isNotEmpty) phones.add(mobile!);
    if (landline != null && landline!.isNotEmpty) phones.add(landline!);
    return phones;
  }
}
