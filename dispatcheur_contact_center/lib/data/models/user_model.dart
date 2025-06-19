import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String name,
    required String email,
    String? avatar,
    String? company,
    String? department,
    String? phone,
    @Default(UserRole.user) UserRole role,
    @Default(UserStatus.offline) UserStatus status,
    DateTime? lastSeen,
    @Default(false) bool isOnline,
    Map<String, dynamic>? preferences,
    VoipCredentials? voipCredentials,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

@freezed
class VoipCredentials with _$VoipCredentials {
  const factory VoipCredentials({
    required String server,
    required String username,
    required String password,
    required String displayName,
    @Default(5060) int port,
    @Default(false) bool secure,
    String? domain,
  }) = _VoipCredentials;

  factory VoipCredentials.fromJson(Map<String, dynamic> json) =>
      _$VoipCredentialsFromJson(json);
}

@JsonEnum()
enum UserRole {
  @JsonValue('admin')
  admin,
  @JsonValue('manager')
  manager,
  @JsonValue('user')
  user,
  @JsonValue('guest')
  guest,
}

@JsonEnum()
enum UserStatus {
  @JsonValue('online')
  online,
  @JsonValue('away')
  away,
  @JsonValue('busy')
  busy,
  @JsonValue('offline')
  offline,
}

// ✅ EXTENSIONS OBRIGATÓRIAS - FORA DA CLASSE FREEZED
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
