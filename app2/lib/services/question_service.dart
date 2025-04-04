import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/question.dart';

class QuestionService {
  Future<List<Question>> fetchQuestions() async {
    try {
      // Cargar el JSON desde los assets
      String jsonString = await rootBundle.loadString('assets/questions.json');
      Map<String, dynamic> jsonData =
          json.decode(jsonString); // Decodificar el JSON

      List<Question> questions =
          (jsonData["preguntas"] as List) // Acceder a la lista de preguntas
              .map((data) => Question.fromJson(data))
              .toList();

      return questions;
    } catch (e) {
      print("❌ Error al cargar preguntas desde JSON: $e");
      return [];
    }
  }
}
