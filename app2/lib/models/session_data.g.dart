// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SessionDataAdapter extends TypeAdapter<SessionData> {
  @override
  final int typeId = 0;

  @override
  SessionData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SessionData(
      timestamp: fields[0] as DateTime?,
      scores: fields[1] as Scores?,
      mood: fields[2] as MoodData?,
      flag: fields[3] as FlagData?,
      recommendations: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SessionData obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.timestamp)
      ..writeByte(1)
      ..write(obj.scores)
      ..writeByte(2)
      ..write(obj.mood)
      ..writeByte(3)
      ..write(obj.flag)
      ..writeByte(4)
      ..write(obj.recommendations);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ScoresAdapter extends TypeAdapter<Scores> {
  @override
  final int typeId = 1;

  @override
  Scores read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Scores(
      scoreDepression: fields[0] as int,
      scoreAnxiety: fields[1] as int,
      scoreStress: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Scores obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.scoreDepression)
      ..writeByte(1)
      ..write(obj.scoreAnxiety)
      ..writeByte(2)
      ..write(obj.scoreStress);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScoresAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MoodDataAdapter extends TypeAdapter<MoodData> {
  @override
  final int typeId = 2;

  @override
  MoodData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MoodData(
      moodLabel: fields[0] as String,
      value: fields[1] as double,
    );
  }

  @override
  void write(BinaryWriter writer, MoodData obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.moodLabel)
      ..writeByte(1)
      ..write(obj.value);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoodDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FlagDataAdapter extends TypeAdapter<FlagData> {
  @override
  final int typeId = 3;

  @override
  FlagData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FlagData(
      prompt: fields[0] as String,
      snippet: fields[1] as String,
      type: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, FlagData obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.prompt)
      ..writeByte(1)
      ..write(obj.snippet)
      ..writeByte(2)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FlagDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecommendationDataAdapter extends TypeAdapter<RecommendationData> {
  @override
  final int typeId = 4;

  @override
  RecommendationData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecommendationData(
      recommendationText: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, RecommendationData obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.recommendationText);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecommendationDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
