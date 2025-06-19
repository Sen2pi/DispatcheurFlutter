// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserModel _$UserModelFromJson(Map<String, dynamic> json) {
  return _UserModel.fromJson(json);
}

/// @nodoc
mixin _$UserModel {
  @HiveField(0)
  String get id => throw _privateConstructorUsedError;
  @HiveField(1)
  String get name => throw _privateConstructorUsedError;
  @HiveField(2)
  String get email => throw _privateConstructorUsedError;
  @HiveField(3)
  String? get avatar => throw _privateConstructorUsedError;
  @HiveField(4)
  String? get company => throw _privateConstructorUsedError;
  @HiveField(5)
  String? get department => throw _privateConstructorUsedError;
  @HiveField(6)
  String? get phone => throw _privateConstructorUsedError;
  @HiveField(7)
  UserRole get role => throw _privateConstructorUsedError;
  @HiveField(8)
  UserStatus get status => throw _privateConstructorUsedError;
  @HiveField(9)
  DateTime? get lastSeen => throw _privateConstructorUsedError;
  @HiveField(10)
  bool get isOnline => throw _privateConstructorUsedError;
  @HiveField(11)
  Map<String, dynamic>? get preferences => throw _privateConstructorUsedError;
  @HiveField(12)
  VoipCredentials? get voipCredentials => throw _privateConstructorUsedError;
  @HiveField(13)
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @HiveField(14)
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserModelCopyWith<UserModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserModelCopyWith<$Res> {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) then) =
      _$UserModelCopyWithImpl<$Res, UserModel>;
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) String name,
      @HiveField(2) String email,
      @HiveField(3) String? avatar,
      @HiveField(4) String? company,
      @HiveField(5) String? department,
      @HiveField(6) String? phone,
      @HiveField(7) UserRole role,
      @HiveField(8) UserStatus status,
      @HiveField(9) DateTime? lastSeen,
      @HiveField(10) bool isOnline,
      @HiveField(11) Map<String, dynamic>? preferences,
      @HiveField(12) VoipCredentials? voipCredentials,
      @HiveField(13) DateTime? createdAt,
      @HiveField(14) DateTime? updatedAt});

  $VoipCredentialsCopyWith<$Res>? get voipCredentials;
}

/// @nodoc
class _$UserModelCopyWithImpl<$Res, $Val extends UserModel>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? email = null,
    Object? avatar = freezed,
    Object? company = freezed,
    Object? department = freezed,
    Object? phone = freezed,
    Object? role = null,
    Object? status = null,
    Object? lastSeen = freezed,
    Object? isOnline = null,
    Object? preferences = freezed,
    Object? voipCredentials = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      avatar: freezed == avatar
          ? _value.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String?,
      company: freezed == company
          ? _value.company
          : company // ignore: cast_nullable_to_non_nullable
              as String?,
      department: freezed == department
          ? _value.department
          : department // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as UserRole,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as UserStatus,
      lastSeen: freezed == lastSeen
          ? _value.lastSeen
          : lastSeen // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isOnline: null == isOnline
          ? _value.isOnline
          : isOnline // ignore: cast_nullable_to_non_nullable
              as bool,
      preferences: freezed == preferences
          ? _value.preferences
          : preferences // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      voipCredentials: freezed == voipCredentials
          ? _value.voipCredentials
          : voipCredentials // ignore: cast_nullable_to_non_nullable
              as VoipCredentials?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VoipCredentialsCopyWith<$Res>? get voipCredentials {
    if (_value.voipCredentials == null) {
      return null;
    }

    return $VoipCredentialsCopyWith<$Res>(_value.voipCredentials!, (value) {
      return _then(_value.copyWith(voipCredentials: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UserModelImplCopyWith<$Res>
    implements $UserModelCopyWith<$Res> {
  factory _$$UserModelImplCopyWith(
          _$UserModelImpl value, $Res Function(_$UserModelImpl) then) =
      __$$UserModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) String name,
      @HiveField(2) String email,
      @HiveField(3) String? avatar,
      @HiveField(4) String? company,
      @HiveField(5) String? department,
      @HiveField(6) String? phone,
      @HiveField(7) UserRole role,
      @HiveField(8) UserStatus status,
      @HiveField(9) DateTime? lastSeen,
      @HiveField(10) bool isOnline,
      @HiveField(11) Map<String, dynamic>? preferences,
      @HiveField(12) VoipCredentials? voipCredentials,
      @HiveField(13) DateTime? createdAt,
      @HiveField(14) DateTime? updatedAt});

  @override
  $VoipCredentialsCopyWith<$Res>? get voipCredentials;
}

/// @nodoc
class __$$UserModelImplCopyWithImpl<$Res>
    extends _$UserModelCopyWithImpl<$Res, _$UserModelImpl>
    implements _$$UserModelImplCopyWith<$Res> {
  __$$UserModelImplCopyWithImpl(
      _$UserModelImpl _value, $Res Function(_$UserModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? email = null,
    Object? avatar = freezed,
    Object? company = freezed,
    Object? department = freezed,
    Object? phone = freezed,
    Object? role = null,
    Object? status = null,
    Object? lastSeen = freezed,
    Object? isOnline = null,
    Object? preferences = freezed,
    Object? voipCredentials = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$UserModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      avatar: freezed == avatar
          ? _value.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String?,
      company: freezed == company
          ? _value.company
          : company // ignore: cast_nullable_to_non_nullable
              as String?,
      department: freezed == department
          ? _value.department
          : department // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as UserRole,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as UserStatus,
      lastSeen: freezed == lastSeen
          ? _value.lastSeen
          : lastSeen // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isOnline: null == isOnline
          ? _value.isOnline
          : isOnline // ignore: cast_nullable_to_non_nullable
              as bool,
      preferences: freezed == preferences
          ? _value._preferences
          : preferences // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      voipCredentials: freezed == voipCredentials
          ? _value.voipCredentials
          : voipCredentials // ignore: cast_nullable_to_non_nullable
              as VoipCredentials?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserModelImpl implements _UserModel {
  const _$UserModelImpl(
      {@HiveField(0) required this.id,
      @HiveField(1) required this.name,
      @HiveField(2) required this.email,
      @HiveField(3) this.avatar,
      @HiveField(4) this.company,
      @HiveField(5) this.department,
      @HiveField(6) this.phone,
      @HiveField(7) this.role = UserRole.user,
      @HiveField(8) this.status = UserStatus.offline,
      @HiveField(9) this.lastSeen,
      @HiveField(10) this.isOnline = false,
      @HiveField(11) final Map<String, dynamic>? preferences,
      @HiveField(12) this.voipCredentials,
      @HiveField(13) this.createdAt,
      @HiveField(14) this.updatedAt})
      : _preferences = preferences;

  factory _$UserModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserModelImplFromJson(json);

  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final String name;
  @override
  @HiveField(2)
  final String email;
  @override
  @HiveField(3)
  final String? avatar;
  @override
  @HiveField(4)
  final String? company;
  @override
  @HiveField(5)
  final String? department;
  @override
  @HiveField(6)
  final String? phone;
  @override
  @JsonKey()
  @HiveField(7)
  final UserRole role;
  @override
  @JsonKey()
  @HiveField(8)
  final UserStatus status;
  @override
  @HiveField(9)
  final DateTime? lastSeen;
  @override
  @JsonKey()
  @HiveField(10)
  final bool isOnline;
  final Map<String, dynamic>? _preferences;
  @override
  @HiveField(11)
  Map<String, dynamic>? get preferences {
    final value = _preferences;
    if (value == null) return null;
    if (_preferences is EqualUnmodifiableMapView) return _preferences;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @HiveField(12)
  final VoipCredentials? voipCredentials;
  @override
  @HiveField(13)
  final DateTime? createdAt;
  @override
  @HiveField(14)
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, avatar: $avatar, company: $company, department: $department, phone: $phone, role: $role, status: $status, lastSeen: $lastSeen, isOnline: $isOnline, preferences: $preferences, voipCredentials: $voipCredentials, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.avatar, avatar) || other.avatar == avatar) &&
            (identical(other.company, company) || other.company == company) &&
            (identical(other.department, department) ||
                other.department == department) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.lastSeen, lastSeen) ||
                other.lastSeen == lastSeen) &&
            (identical(other.isOnline, isOnline) ||
                other.isOnline == isOnline) &&
            const DeepCollectionEquality()
                .equals(other._preferences, _preferences) &&
            (identical(other.voipCredentials, voipCredentials) ||
                other.voipCredentials == voipCredentials) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      email,
      avatar,
      company,
      department,
      phone,
      role,
      status,
      lastSeen,
      isOnline,
      const DeepCollectionEquality().hash(_preferences),
      voipCredentials,
      createdAt,
      updatedAt);

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      __$$UserModelImplCopyWithImpl<_$UserModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserModelImplToJson(
      this,
    );
  }
}

abstract class _UserModel implements UserModel {
  const factory _UserModel(
      {@HiveField(0) required final String id,
      @HiveField(1) required final String name,
      @HiveField(2) required final String email,
      @HiveField(3) final String? avatar,
      @HiveField(4) final String? company,
      @HiveField(5) final String? department,
      @HiveField(6) final String? phone,
      @HiveField(7) final UserRole role,
      @HiveField(8) final UserStatus status,
      @HiveField(9) final DateTime? lastSeen,
      @HiveField(10) final bool isOnline,
      @HiveField(11) final Map<String, dynamic>? preferences,
      @HiveField(12) final VoipCredentials? voipCredentials,
      @HiveField(13) final DateTime? createdAt,
      @HiveField(14) final DateTime? updatedAt}) = _$UserModelImpl;

  factory _UserModel.fromJson(Map<String, dynamic> json) =
      _$UserModelImpl.fromJson;

  @override
  @HiveField(0)
  String get id;
  @override
  @HiveField(1)
  String get name;
  @override
  @HiveField(2)
  String get email;
  @override
  @HiveField(3)
  String? get avatar;
  @override
  @HiveField(4)
  String? get company;
  @override
  @HiveField(5)
  String? get department;
  @override
  @HiveField(6)
  String? get phone;
  @override
  @HiveField(7)
  UserRole get role;
  @override
  @HiveField(8)
  UserStatus get status;
  @override
  @HiveField(9)
  DateTime? get lastSeen;
  @override
  @HiveField(10)
  bool get isOnline;
  @override
  @HiveField(11)
  Map<String, dynamic>? get preferences;
  @override
  @HiveField(12)
  VoipCredentials? get voipCredentials;
  @override
  @HiveField(13)
  DateTime? get createdAt;
  @override
  @HiveField(14)
  DateTime? get updatedAt;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

VoipCredentials _$VoipCredentialsFromJson(Map<String, dynamic> json) {
  return _VoipCredentials.fromJson(json);
}

/// @nodoc
mixin _$VoipCredentials {
  @HiveField(0)
  String get server => throw _privateConstructorUsedError;
  @HiveField(1)
  String get username => throw _privateConstructorUsedError;
  @HiveField(2)
  String get password => throw _privateConstructorUsedError;
  @HiveField(3)
  String get displayName => throw _privateConstructorUsedError;
  @HiveField(4)
  int get port => throw _privateConstructorUsedError;
  @HiveField(5)
  bool get secure => throw _privateConstructorUsedError;
  @HiveField(6)
  String? get domain => throw _privateConstructorUsedError;

  /// Serializes this VoipCredentials to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VoipCredentials
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VoipCredentialsCopyWith<VoipCredentials> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VoipCredentialsCopyWith<$Res> {
  factory $VoipCredentialsCopyWith(
          VoipCredentials value, $Res Function(VoipCredentials) then) =
      _$VoipCredentialsCopyWithImpl<$Res, VoipCredentials>;
  @useResult
  $Res call(
      {@HiveField(0) String server,
      @HiveField(1) String username,
      @HiveField(2) String password,
      @HiveField(3) String displayName,
      @HiveField(4) int port,
      @HiveField(5) bool secure,
      @HiveField(6) String? domain});
}

/// @nodoc
class _$VoipCredentialsCopyWithImpl<$Res, $Val extends VoipCredentials>
    implements $VoipCredentialsCopyWith<$Res> {
  _$VoipCredentialsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VoipCredentials
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? server = null,
    Object? username = null,
    Object? password = null,
    Object? displayName = null,
    Object? port = null,
    Object? secure = null,
    Object? domain = freezed,
  }) {
    return _then(_value.copyWith(
      server: null == server
          ? _value.server
          : server // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      port: null == port
          ? _value.port
          : port // ignore: cast_nullable_to_non_nullable
              as int,
      secure: null == secure
          ? _value.secure
          : secure // ignore: cast_nullable_to_non_nullable
              as bool,
      domain: freezed == domain
          ? _value.domain
          : domain // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VoipCredentialsImplCopyWith<$Res>
    implements $VoipCredentialsCopyWith<$Res> {
  factory _$$VoipCredentialsImplCopyWith(_$VoipCredentialsImpl value,
          $Res Function(_$VoipCredentialsImpl) then) =
      __$$VoipCredentialsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) String server,
      @HiveField(1) String username,
      @HiveField(2) String password,
      @HiveField(3) String displayName,
      @HiveField(4) int port,
      @HiveField(5) bool secure,
      @HiveField(6) String? domain});
}

/// @nodoc
class __$$VoipCredentialsImplCopyWithImpl<$Res>
    extends _$VoipCredentialsCopyWithImpl<$Res, _$VoipCredentialsImpl>
    implements _$$VoipCredentialsImplCopyWith<$Res> {
  __$$VoipCredentialsImplCopyWithImpl(
      _$VoipCredentialsImpl _value, $Res Function(_$VoipCredentialsImpl) _then)
      : super(_value, _then);

  /// Create a copy of VoipCredentials
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? server = null,
    Object? username = null,
    Object? password = null,
    Object? displayName = null,
    Object? port = null,
    Object? secure = null,
    Object? domain = freezed,
  }) {
    return _then(_$VoipCredentialsImpl(
      server: null == server
          ? _value.server
          : server // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      port: null == port
          ? _value.port
          : port // ignore: cast_nullable_to_non_nullable
              as int,
      secure: null == secure
          ? _value.secure
          : secure // ignore: cast_nullable_to_non_nullable
              as bool,
      domain: freezed == domain
          ? _value.domain
          : domain // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VoipCredentialsImpl implements _VoipCredentials {
  const _$VoipCredentialsImpl(
      {@HiveField(0) required this.server,
      @HiveField(1) required this.username,
      @HiveField(2) required this.password,
      @HiveField(3) required this.displayName,
      @HiveField(4) this.port = 5060,
      @HiveField(5) this.secure = false,
      @HiveField(6) this.domain});

  factory _$VoipCredentialsImpl.fromJson(Map<String, dynamic> json) =>
      _$$VoipCredentialsImplFromJson(json);

  @override
  @HiveField(0)
  final String server;
  @override
  @HiveField(1)
  final String username;
  @override
  @HiveField(2)
  final String password;
  @override
  @HiveField(3)
  final String displayName;
  @override
  @JsonKey()
  @HiveField(4)
  final int port;
  @override
  @JsonKey()
  @HiveField(5)
  final bool secure;
  @override
  @HiveField(6)
  final String? domain;

  @override
  String toString() {
    return 'VoipCredentials(server: $server, username: $username, password: $password, displayName: $displayName, port: $port, secure: $secure, domain: $domain)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VoipCredentialsImpl &&
            (identical(other.server, server) || other.server == server) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.port, port) || other.port == port) &&
            (identical(other.secure, secure) || other.secure == secure) &&
            (identical(other.domain, domain) || other.domain == domain));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, server, username, password,
      displayName, port, secure, domain);

  /// Create a copy of VoipCredentials
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VoipCredentialsImplCopyWith<_$VoipCredentialsImpl> get copyWith =>
      __$$VoipCredentialsImplCopyWithImpl<_$VoipCredentialsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VoipCredentialsImplToJson(
      this,
    );
  }
}

abstract class _VoipCredentials implements VoipCredentials {
  const factory _VoipCredentials(
      {@HiveField(0) required final String server,
      @HiveField(1) required final String username,
      @HiveField(2) required final String password,
      @HiveField(3) required final String displayName,
      @HiveField(4) final int port,
      @HiveField(5) final bool secure,
      @HiveField(6) final String? domain}) = _$VoipCredentialsImpl;

  factory _VoipCredentials.fromJson(Map<String, dynamic> json) =
      _$VoipCredentialsImpl.fromJson;

  @override
  @HiveField(0)
  String get server;
  @override
  @HiveField(1)
  String get username;
  @override
  @HiveField(2)
  String get password;
  @override
  @HiveField(3)
  String get displayName;
  @override
  @HiveField(4)
  int get port;
  @override
  @HiveField(5)
  bool get secure;
  @override
  @HiveField(6)
  String? get domain;

  /// Create a copy of VoipCredentials
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VoipCredentialsImplCopyWith<_$VoipCredentialsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
