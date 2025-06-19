// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notes_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$NotesState {
  List<NoteModel> get notes => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Create a copy of NotesState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotesStateCopyWith<NotesState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotesStateCopyWith<$Res> {
  factory $NotesStateCopyWith(
          NotesState value, $Res Function(NotesState) then) =
      _$NotesStateCopyWithImpl<$Res, NotesState>;
  @useResult
  $Res call({List<NoteModel> notes, bool isLoading, String? error});
}

/// @nodoc
class _$NotesStateCopyWithImpl<$Res, $Val extends NotesState>
    implements $NotesStateCopyWith<$Res> {
  _$NotesStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotesState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? notes = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      notes: null == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as List<NoteModel>,
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
abstract class _$$NotesStateImplCopyWith<$Res>
    implements $NotesStateCopyWith<$Res> {
  factory _$$NotesStateImplCopyWith(
          _$NotesStateImpl value, $Res Function(_$NotesStateImpl) then) =
      __$$NotesStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<NoteModel> notes, bool isLoading, String? error});
}

/// @nodoc
class __$$NotesStateImplCopyWithImpl<$Res>
    extends _$NotesStateCopyWithImpl<$Res, _$NotesStateImpl>
    implements _$$NotesStateImplCopyWith<$Res> {
  __$$NotesStateImplCopyWithImpl(
      _$NotesStateImpl _value, $Res Function(_$NotesStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of NotesState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? notes = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_$NotesStateImpl(
      notes: null == notes
          ? _value._notes
          : notes // ignore: cast_nullable_to_non_nullable
              as List<NoteModel>,
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

class _$NotesStateImpl implements _NotesState {
  const _$NotesStateImpl(
      {final List<NoteModel> notes = const [],
      this.isLoading = false,
      this.error})
      : _notes = notes;

  final List<NoteModel> _notes;
  @override
  @JsonKey()
  List<NoteModel> get notes {
    if (_notes is EqualUnmodifiableListView) return _notes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_notes);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;

  @override
  String toString() {
    return 'NotesState(notes: $notes, isLoading: $isLoading, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotesStateImpl &&
            const DeepCollectionEquality().equals(other._notes, _notes) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_notes), isLoading, error);

  /// Create a copy of NotesState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotesStateImplCopyWith<_$NotesStateImpl> get copyWith =>
      __$$NotesStateImplCopyWithImpl<_$NotesStateImpl>(this, _$identity);
}

abstract class _NotesState implements NotesState {
  const factory _NotesState(
      {final List<NoteModel> notes,
      final bool isLoading,
      final String? error}) = _$NotesStateImpl;

  @override
  List<NoteModel> get notes;
  @override
  bool get isLoading;
  @override
  String? get error;

  /// Create a copy of NotesState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotesStateImplCopyWith<_$NotesStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
