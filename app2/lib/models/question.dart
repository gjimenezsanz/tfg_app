class Question {
  final String question;
  final List<String> options;
  final String category;

  Question({
    required this.question,
    required this.options,
    required this.category,
  });

  // Convertir desde JSON (questions.json) => Map
  factory Question.fromJson(Map<String, dynamic> json) => Question(
        question: json["question"] as String,
        options: List<String>.from(json["options"]),
        category: json["category"] as String, // <-- lee un String
      );
}
