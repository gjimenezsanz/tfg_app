class QuestionLoneliness {
  final String pregunta;
  final List<String> opciones;

  QuestionLoneliness({
    required this.pregunta,
    required this.opciones,
  });

  factory QuestionLoneliness.fromFirestore(Map<String, dynamic> data) {
    return QuestionLoneliness(
      pregunta: data["pregunta"] as String,
      opciones: List<String>.from(data["opciones"] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "pregunta": pregunta,
      "opciones": opciones,
    };
  }
}
