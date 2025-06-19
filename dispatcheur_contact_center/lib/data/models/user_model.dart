import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
@HiveType(typeId: 6)
class UserModel with _$UserModel {
  const factory UserModel({
    @HiveField(0) required String id,
    @HiveField(1) required String name,
    @HiveField(2) required String email,
    @HiveField(3) String? avatar,
    @HiveField(4) String? company,
    @HiveField(5) String? department,
    @HiveField(6) String? phone,
    @HiveField(7) @Default(UserRole.user) UserRole role,
    @HiveField(8) @Default(UserStatus.offline) UserStatus status,
    @HiveField(9) DateTime? lastSeen,
    @HiveField(10) @Default(false) bool isOnline,
    @HiveField(11) Map<String, dynamic>? preferences,
    @HiveField(12) VoipCredentials? voipCredentials,
    @HiveField(13) DateTime? createdAt,
    @HiveField(14) DateTime? updatedAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

@freezed
@HiveType(typeId: 7)
class VoipCredentials with _$VoipCredentials {
  const factory VoipCredentials({
    @HiveField(0) required String server,
    @HiveField(1) required String username,
    @HiveField(2) required String password,
    @HiveField(3) required String displayName,
    @HiveField(4) @Default(5060) int port,
    @HiveField(5) @Default(false) bool secure,
    @HiveField(6) String? domain,
  }) = _VoipCredentials;

  factory VoipCredentials.fromJson(Map<String, dynamic> json) =>
      _$VoipCredentialsFromJson(json);
}

@HiveType(typeId: 8)
enum UserRole {
  @HiveField(0)
  admin,
  @HiveField(1)
  manager,
  @HiveField(2)
  user,
  @HiveField(3)
  guest,
}

@HiveType(typeId: 9)
enum UserStatus {
  @HiveField(0)
  online,
  @HiveField(1)
  away,
  @HiveField(2)
  busy,
  @HiveField(3)
  offline,
}

extension UserModelExtensions on UserModel {
  String get initials {
    final words = name.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return name.length >= 2
        ? name.substring(0, 2).toUpperCase()
        : name.toUpperCase();
  }

  String get displayName => name.isEmpty ? 'Utilizador' : name;

  String get statusText {
    switch (status) {
      case UserStatus.online:
        return 'Online';
      case UserStatus.away:
        return 'Ausente';
      case UserStatus.busy:
        return 'Ocupado';
      case UserStatus.offline:
        return 'Offline';
    }
  }

  Color get statusColor {
    switch (status) {
      case UserStatus.online:
        return const Color(0xFF22c55e);
      case UserStatus.away:
        return const Color(0xFFf59e0b);
      case UserStatus.busy:
        return const Color(0xFFef4444);
      case UserStatus.offline:
        return const Color(0xFF64748b);
    }
  }

  bool get hasVoipCredentials => voipCredentials != null;

  bool get isActive =>
      isOnline && (status == UserStatus.online || status == UserStatus.away);
}
