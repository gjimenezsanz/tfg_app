class Question {
  final String pregunta;
  final List<String> opciones;
  final String category;

  Question({
    required this.pregunta,
    required this.opciones,
    required this.category,
  });

  // Convertir desde JSON (questions.json) => Map
  factory Question.fromJson(Map<String, dynamic> json) => Question(
        pregunta: json["pregunta"] as String,
        opciones: List<String>.from(json["opciones"]),
        category: json["category"] as String, // <-- lee un String
      );
}
