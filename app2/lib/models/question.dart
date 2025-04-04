import 'dart:convert';

class Question {
  final String pregunta;
  final List<String> opciones;

  Question({
    required this.pregunta,
    required this.opciones,
  });

  // Convertir desde JSON (questions.json) => Map
  factory Question.fromJson(Map<String, dynamic> data) {
    return Question(
      pregunta: data["pregunta"] as String,
      opciones: List<String>.from(data["opciones"] ?? []),
    );
  }
}
