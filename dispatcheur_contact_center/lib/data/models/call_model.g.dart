// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CallModelAdapter extends TypeAdapter<CallModel> {
  @override
  final int typeId = 0;

  @override
  CallModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CallModel();
  }

  @override
  void write(BinaryWriter writer, CallModel obj) {
    writer.writeByte(0);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CallModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CallDirectionAdapter extends TypeAdapter<CallDirection> {
  @override
  final int typeId = 1;

  @override
  CallDirection read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CallDirection.incoming;
      case 1:
        return CallDirection.outgoing;
      default:
        return CallDirection.incoming;
    }
  }

  @override
  void write(BinaryWriter writer, CallDirection obj) {
    switch (obj) {
      case CallDirection.incoming:
        writer.writeByte(0);
        break;
      case CallDirection.outgoing:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CallDirectionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CallStateAdapter extends TypeAdapter<CallState> {
  @override
  final int typeId = 2;

  @override
  CallState read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CallState.connecting;
      case 1:
        return CallState.ringing;
      case 2:
        return CallState.established;
      case 3:
        return CallState.held;
      case 4:
        return CallState.ended;
      case 5:
        return CallState.failed;
      case 6:
        return CallState.terminated;
      default:
        return CallState.connecting;
    }
  }

  @override
  void write(BinaryWriter writer, CallState obj) {
    switch (obj) {
      case CallState.connecting:
        writer.writeByte(0);
        break;
      case CallState.ringing:
        writer.writeByte(1);
        break;
      case CallState.established:
        writer.writeByte(2);
        break;
      case CallState.held:
        writer.writeByte(3);
        break;
      case CallState.ended:
        writer.writeByte(4);
        break;
      case CallState.failed:
        writer.writeByte(5);
        break;
      case CallState.terminated:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CallStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
