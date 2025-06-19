// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 6;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      id: fields[0] as String,
      name: fields[1] as String,
      email: fields[2] as String,
      avatar: fields[3] as String?,
      company: fields[4] as String?,
      department: fields[5] as String?,
      phone: fields[6] as String?,
      role: fields[7] as UserRole,
      status: fields[8] as UserStatus,
      lastSeen: fields[9] as DateTime?,
      isOnline: fields[10] as bool,
      preferences: (fields[11] as Map?)?.cast<String, dynamic>(),
      voipCredentials: fields[12] as VoipCredentials?,
      createdAt: fields[13] as DateTime?,
      updatedAt: fields[14] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.avatar)
      ..writeByte(4)
      ..write(obj.company)
      ..writeByte(5)
      ..write(obj.department)
      ..writeByte(6)
      ..write(obj.phone)
      ..writeByte(7)
      ..write(obj.role)
      ..writeByte(8)
      ..write(obj.status)
      ..writeByte(9)
      ..write(obj.lastSeen)
      ..writeByte(10)
      ..write(obj.isOnline)
      ..writeByte(11)
      ..write(obj.preferences)
      ..writeByte(12)
      ..write(obj.voipCredentials)
      ..writeByte(13)
      ..write(obj.createdAt)
      ..writeByte(14)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class VoipCredentialsAdapter extends TypeAdapter<VoipCredentials> {
  @override
  final int typeId = 7;

  @override
  VoipCredentials read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VoipCredentials(
      server: fields[0] as String,
      username: fields[1] as String,
      password: fields[2] as String,
      displayName: fields[3] as String,
      port: fields[4] as int,
      secure: fields[5] as bool,
      domain: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, VoipCredentials obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.server)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.password)
      ..writeByte(3)
      ..write(obj.displayName)
      ..writeByte(4)
      ..write(obj.port)
      ..writeByte(5)
      ..write(obj.secure)
      ..writeByte(6)
      ..write(obj.domain);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoipCredentialsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserRoleAdapter extends TypeAdapter<UserRole> {
  @override
  final int typeId = 8;

  @override
  UserRole read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return UserRole.admin;
      case 1:
        return UserRole.manager;
      case 2:
        return UserRole.user;
      case 3:
        return UserRole.guest;
      default:
        return UserRole.admin;
    }
  }

  @override
  void write(BinaryWriter writer, UserRole obj) {
    switch (obj) {
      case UserRole.admin:
        writer.writeByte(0);
        break;
      case UserRole.manager:
        writer.writeByte(1);
        break;
      case UserRole.user:
        writer.writeByte(2);
        break;
      case UserRole.guest:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserRoleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserStatusAdapter extends TypeAdapter<UserStatus> {
  @override
  final int typeId = 9;

  @override
  UserStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return UserStatus.online;
      case 1:
        return UserStatus.away;
      case 2:
        return UserStatus.busy;
      case 3:
        return UserStatus.offline;
      default:
        return UserStatus.online;
    }
  }

  @override
  void write(BinaryWriter writer, UserStatus obj) {
    switch (obj) {
      case UserStatus.online:
        writer.writeByte(0);
        break;
      case UserStatus.away:
        writer.writeByte(1);
        break;
      case UserStatus.busy:
        writer.writeByte(2);
        break;
      case UserStatus.offline:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserModelImpl _$$UserModelImplFromJson(Map<String, dynamic> json) =>
    _$UserModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatar: json['avatar'] as String?,
      company: json['company'] as String?,
      department: json['department'] as String?,
      phone: json['phone'] as String?,
      role:
          $enumDecodeNullable(_$UserRoleEnumMap, json['role']) ?? UserRole.user,
      status: $enumDecodeNullable(_$UserStatusEnumMap, json['status']) ??
          UserStatus.offline,
      lastSeen: json['lastSeen'] == null
          ? null
          : DateTime.parse(json['lastSeen'] as String),
      isOnline: json['isOnline'] as bool? ?? false,
      preferences: json['preferences'] as Map<String, dynamic>?,
      voipCredentials: json['voipCredentials'] == null
          ? null
          : VoipCredentials.fromJson(
              json['voipCredentials'] as Map<String, dynamic>),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'avatar': instance.avatar,
      'company': instance.company,
      'department': instance.department,
      'phone': instance.phone,
      'role': _$UserRoleEnumMap[instance.role]!,
      'status': _$UserStatusEnumMap[instance.status]!,
      'lastSeen': instance.lastSeen?.toIso8601String(),
      'isOnline': instance.isOnline,
      'preferences': instance.preferences,
      'voipCredentials': instance.voipCredentials,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$UserRoleEnumMap = {
  UserRole.admin: 'admin',
  UserRole.manager: 'manager',
  UserRole.user: 'user',
  UserRole.guest: 'guest',
};

const _$UserStatusEnumMap = {
  UserStatus.online: 'online',
  UserStatus.away: 'away',
  UserStatus.busy: 'busy',
  UserStatus.offline: 'offline',
};

_$VoipCredentialsImpl _$$VoipCredentialsImplFromJson(
        Map<String, dynamic> json) =>
    _$VoipCredentialsImpl(
      server: json['server'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
      displayName: json['displayName'] as String,
      port: (json['port'] as num?)?.toInt() ?? 5060,
      secure: json['secure'] as bool? ?? false,
      domain: json['domain'] as String?,
    );

Map<String, dynamic> _$$VoipCredentialsImplToJson(
        _$VoipCredentialsImpl instance) =>
    <String, dynamic>{
      'server': instance.server,
      'username': instance.username,
      'password': instance.password,
      'displayName': instance.displayName,
      'port': instance.port,
      'secure': instance.secure,
      'domain': instance.domain,
    };
