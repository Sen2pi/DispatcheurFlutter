import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'call_model.freezed.dart';
part 'call_model.g.dart';

@freezed
@HiveType(typeId: 0)
class CallModel with _$CallModel {
  const factory CallModel({
    @HiveField(0) required String id,
    @HiveField(1) required String destination,
    @HiveField(2) required CallDirection direction,
    @HiveField(3) required CallState state,
    @HiveField(4) required DateTime startTime,
    @HiveField(5) @Default(false) bool isHeld,
    @HiveField(6) @Default(false) bool isConference,
    @HiveField(7) @Default(false) bool isMuted,
    @HiveField(8) @Default(false) bool isActive,
    @HiveField(9) String? displayName,
    @HiveField(10) DateTime? answeredTime,
    @HiveField(11) DateTime? endTime,
    @HiveField(12) @Default([]) List<String> participants,
    @HiveField(13) String? transferTarget,
    @HiveField(14) @Default(false) bool isOutbound,
    @HiveField(15) Map<String, dynamic>? metadata,
  }) = _CallModel;

  factory CallModel.fromJson(Map<String, dynamic> json) =>
      _$CallModelFromJson(json);
}

@HiveType(typeId: 1)
enum CallDirection {
  @HiveField(0)
  incoming,
  @HiveField(1)
  outgoing,
}

@HiveType(typeId: 2)
enum CallState {
  @HiveField(0)
  connecting,
  @HiveField(1)
  ringing,
  @HiveField(2)
  established,
  @HiveField(3)
  held,
  @HiveField(4)
  ended,
  @HiveField(5)
  failed,
  @HiveField(6)
  terminated,
}

extension CallModelExtensions on CallModel {
  String get formattedDuration {
    final now = DateTime.now();
    final start = answeredTime ?? startTime;
    final end = endTime ?? (state == CallState.ended ? now : now);

    final duration = end.difference(start);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  bool get canAnswer =>
      state == CallState.ringing && direction == CallDirection.incoming;
  bool get canHold => state == CallState.established && !isHeld;
  bool get canResume => state == CallState.established && isHeld;
  bool get canTransfer => state == CallState.established;
  bool get canSendDTMF => state == CallState.established;
  bool get canHangup => state != CallState.ended && state != CallState.failed;

  String get statusText {
    switch (state) {
      case CallState.connecting:
        return 'Conectando...';
      case CallState.ringing:
        return direction == CallDirection.incoming ? 'Tocando' : 'Chamando...';
      case CallState.established:
        return isHeld ? 'Em espera' : 'Ativo';
      case CallState.ended:
        return 'Finalizada';
      case CallState.failed:
        return 'Falhou';
      case CallState.terminated:
        return 'Terminada';
      default:
        return 'Desconhecido';
    }
  }
}
