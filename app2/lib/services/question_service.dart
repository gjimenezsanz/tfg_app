import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/question_loneliness.dart';

class QuestionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<QuestionLoneliness>> fetchQuestions() async {
    try {
      var snapshot = await _db
          .collection("cuestionarios")
          .doc("cuestionario_loneliness")
          .get();

      if (!snapshot.exists) {
        print("❌ No se encontraron preguntas.");
        return [];
      }

      var data = snapshot.data();
      if (data == null || !data.containsKey("preguntas")) {
        print("❌ Error: El documento no tiene el campo 'preguntas'.");
        return [];
      }

      List<dynamic> preguntasData = data["preguntas"];

      if (preguntasData.isEmpty) {
        print("⚠️ Advertencia: No hay preguntas en la base de datos.");
        return [];
      }

      // Transformar los datos en una lista de objetos QuestionLoneliness
      List<QuestionLoneliness> questions = preguntasData.map((preguntaMap) {
        return QuestionLoneliness.fromFirestore(
            preguntaMap as Map<String, dynamic>);
      }).toList();

      print("📌 Preguntas cargadas correctamente: ${questions.length}");
      return questions;
    } catch (e) {
      print("❌ Error al obtener preguntas: $e");
      return [];
    }
  }
}
