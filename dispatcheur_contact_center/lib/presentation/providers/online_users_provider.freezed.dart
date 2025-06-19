// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'online_users_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$OnlineUsersState {
  List<UserModel> get users => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Create a copy of OnlineUsersState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OnlineUsersStateCopyWith<OnlineUsersState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OnlineUsersStateCopyWith<$Res> {
  factory $OnlineUsersStateCopyWith(
          OnlineUsersState value, $Res Function(OnlineUsersState) then) =
      _$OnlineUsersStateCopyWithImpl<$Res, OnlineUsersState>;
  @useResult
  $Res call({List<UserModel> users, bool isLoading, String? error});
}

/// @nodoc
class _$OnlineUsersStateCopyWithImpl<$Res, $Val extends OnlineUsersState>
    implements $OnlineUsersStateCopyWith<$Res> {
  _$OnlineUsersStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OnlineUsersState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? users = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      users: null == users
          ? _value.users
          : users // ignore: cast_nullable_to_non_nullable
              as List<UserModel>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OnlineUsersStateImplCopyWith<$Res>
    implements $OnlineUsersStateCopyWith<$Res> {
  factory _$$OnlineUsersStateImplCopyWith(_$OnlineUsersStateImpl value,
          $Res Function(_$OnlineUsersStateImpl) then) =
      __$$OnlineUsersStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<UserModel> users, bool isLoading, String? error});
}

/// @nodoc
class __$$OnlineUsersStateImplCopyWithImpl<$Res>
    extends _$OnlineUsersStateCopyWithImpl<$Res, _$OnlineUsersStateImpl>
    implements _$$OnlineUsersStateImplCopyWith<$Res> {
  __$$OnlineUsersStateImplCopyWithImpl(_$OnlineUsersStateImpl _value,
      $Res Function(_$OnlineUsersStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of OnlineUsersState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? users = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_$OnlineUsersStateImpl(
      users: null == users
          ? _value._users
          : users // ignore: cast_nullable_to_non_nullable
              as List<UserModel>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$OnlineUsersStateImpl implements _OnlineUsersState {
  const _$OnlineUsersStateImpl(
      {final List<UserModel> users = const [],
      this.isLoading = false,
      this.error})
      : _users = users;

  final List<UserModel> _users;
  @override
  @JsonKey()
  List<UserModel> get users {
    if (_users is EqualUnmodifiableListView) return _users;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_users);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;

  @override
  String toString() {
    return 'OnlineUsersState(users: $users, isLoading: $isLoading, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OnlineUsersStateImpl &&
            const DeepCollectionEquality().equals(other._users, _users) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_users), isLoading, error);

  /// Create a copy of OnlineUsersState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OnlineUsersStateImplCopyWith<_$OnlineUsersStateImpl> get copyWith =>
      __$$OnlineUsersStateImplCopyWithImpl<_$OnlineUsersStateImpl>(
          this, _$identity);
}

abstract class _OnlineUsersState implements OnlineUsersState {
  const factory _OnlineUsersState(
      {final List<UserModel> users,
      final bool isLoading,
      final String? error}) = _$OnlineUsersStateImpl;

  @override
  List<UserModel> get users;
  @override
  bool get isLoading;
  @override
  String? get error;

  /// Create a copy of OnlineUsersState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OnlineUsersStateImplCopyWith<_$OnlineUsersStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
