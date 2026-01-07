import 'package:hive/hive.dart';

part 'session_data.g.dart';

@HiveType(typeId: 0)
class SessionData extends HiveObject {
  @HiveField(0)
  DateTime? timestamp; // Última actualización local

  @HiveField(1)
  Scores? scores; // Puntuaciones

  @HiveField(2)
  MoodData? mood; // Estado de ánimo

  @HiveField(3)
  FlagData? flag; // Guardamos un solo flag

  @HiveField(4)
  String? recommendations; // Texto recomendación IA

  SessionData({
    this.timestamp,
    this.scores,
    this.mood,
    this.flag,
    this.recommendations,
  });
}

// Parámetros tipo 1: Puntuación cuestionario
@HiveType(typeId: 1)
class Scores extends HiveObject {
  @HiveField(0)
  int scoreDepression;

  @HiveField(1)
  int scoreAnxiety;

  @HiveField(2)
  int scoreStress;

  Scores({
    required this.scoreDepression,
    required this.scoreAnxiety,
    required this.scoreStress,
  });
}

// Parámetros tipo 2: Barra de estado de ánimo
@HiveType(typeId: 2)
class MoodData extends HiveObject {
  @HiveField(0)
  String moodLabel;

  @HiveField(1)
  double value;

  MoodData({
    required this.moodLabel,
    required this.value,
  });
}

// Parámetros tipo 3: Flags detectado por IA
@HiveType(typeId: 3)
class FlagData extends HiveObject {
  @HiveField(0)
  String prompt;

  @HiveField(1)
  String snippet;

  @HiveField(2)
  String type; // "anxiety", "depression", "stress" o "none"

  FlagData({
    required this.prompt,
    required this.snippet,
    required this.type,
  });
}

// Parámetros tipo 4: Recomendación chat IA
@HiveType(typeId: 4)
class RecommendationData extends HiveObject {
  @HiveField(0)
  String recommendationText;

  RecommendationData({
    required this.recommendationText,
  });
}
