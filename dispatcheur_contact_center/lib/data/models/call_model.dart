import 'package:flutter/foundation.dart';

enum CallDirection { incoming, outgoing }

enum CallState { connecting, ringing, established, held, ended, failed }

@immutable
class CallModel {
  const CallModel({
    required this.id,
    required this.destination,
    required this.direction,
    required this.state,
    required this.startTime,
    this.isHeld = false,
    this.isConference = false,
    this.isMuted = false,
    this.isActive = false,
    this.displayName,
    this.answeredTime,
    this.endTime,
    this.participants = const [],
    this.transferTarget,
    this.isOutbound = false,
    this.metadata = const {},
  });

  final String id;
  final String destination;
  final CallDirection direction;
  final CallState state;
  final DateTime startTime;
  final bool isHeld;
  final bool isConference;
  final bool isMuted;
  final bool isActive;
  final String? displayName;
  final DateTime? answeredTime;
  final DateTime? endTime;
  final List<String> participants;
  final String? transferTarget;
  final bool isOutbound;
  final Map<String, dynamic> metadata;

  CallModel copyWith({
    String? id,
    String? destination,
    CallDirection? direction,
    CallState? state,
    DateTime? startTime,
    bool? isHeld,
    bool? isConference,
    bool? isMuted,
    bool? isActive,
    String? displayName,
    DateTime? answeredTime,
    DateTime? endTime,
    List<String>? participants,
    String? transferTarget,
    bool? isOutbound,
    Map<String, dynamic>? metadata,
  }) {
    return CallModel(
      id: id ?? this.id,
      destination: destination ?? this.destination,
      direction: direction ?? this.direction,
      state: state ?? this.state,
      startTime: startTime ?? this.startTime,
      isHeld: isHeld ?? this.isHeld,
      isConference: isConference ?? this.isConference,
      isMuted: isMuted ?? this.isMuted,
      isActive: isActive ?? this.isActive,
      displayName: displayName ?? this.displayName,
      answeredTime: answeredTime ?? this.answeredTime,
      endTime: endTime ?? this.endTime,
      participants: participants ?? this.participants,
      transferTarget: transferTarget ?? this.transferTarget,
      isOutbound: isOutbound ?? this.isOutbound,
      metadata: metadata ?? this.metadata,
    );
  }

  String get formattedDuration {
    final now = DateTime.now();
    final start = answeredTime ?? startTime;
    final end = endTime ?? (state == CallState.ended ? now : now);

    final duration = end.difference(start);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

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
      default:
        return 'Desconhecido';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'destination': destination,
      'direction': direction.name,
      'state': state.name,
      'startTime': startTime.toIso8601String(),
      'isHeld': isHeld,
      'isConference': isConference,
      'isMuted': isMuted,
      'isActive': isActive,
      'displayName': displayName,
      'answeredTime': answeredTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'participants': participants,
      'transferTarget': transferTarget,
      'isOutbound': isOutbound,
      'metadata': metadata,
    };
  }

  factory CallModel.fromJson(Map<String, dynamic> json) {
    return CallModel(
      id: json['id'] as String,
      destination: json['destination'] as String,
      direction: CallDirection.values.firstWhere(
        (e) => e.name == json['direction'],
        orElse: () => CallDirection.outgoing,
      ),
      state: CallState.values.firstWhere(
        (e) => e.name == json['state'],
        orElse: () => CallState.ended,
      ),
      startTime: DateTime.parse(json['startTime'] as String),
      isHeld: json['isHeld'] as bool? ?? false,
      isConference: json['isConference'] as bool? ?? false,
      isMuted: json['isMuted'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? false,
      displayName: json['displayName'] as String?,
      answeredTime: json['answeredTime'] != null
          ? DateTime.parse(json['answeredTime'] as String)
          : null,
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      participants: List<String>.from(json['participants'] ?? []),
      transferTarget: json['transferTarget'] as String?,
      isOutbound: json['isOutbound'] as bool? ?? false,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
}
