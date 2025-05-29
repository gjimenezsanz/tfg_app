import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform; // Para verificar un servidor distinto
import 'package:flutter/foundation.dart'
    show kIsWeb; // Para verificar un servidor distinto

class RecommendService {
  final String baseUrl = 'https://openrouter.ai/api/v1'; // URL base
  final String apiKey =
      "REDACTED_OPENROUTER_KEY"; //API Key OpenRouter
  //final String referer = '<url>'; // Opcional
  //final String title = '<title>'; // Opcional

  Future<String> sendMessage({
    required int depressionScore,
    required int anxietyScore,
    required int lonelinessScore,
    required String message,
  }) async {
    String getBackendUrl() {
      if (kIsWeb) {
        return 'https://openrouter.ai/api/v1/chat/completions'; //endpoint de OpenRouter: url para peticiones POST
      } else if (Platform.isMacOS) {
        return 'https://openrouter.ai/api/v1/chat/completions'; //url local para peticiones POST
      } else {
        return 'https://openrouter.ai/api/v1/chat/completions'; // por defecto
      }
    }

    final url = Uri.parse('https://openrouter.ai/api/v1/chat/completions');

    final headers = {
      'Content-Type': 'application/json', // Contenido JSON
      'Authorization': 'Bearer $apiKey',
      //'HTTP-Referer': referer,
      //'X-Title': title,
    };

    final body = json.encode({
      'model':
          'meta-llama/llama-3.3-8b-instruct:free', // Modelo de IA a utilizar
      'messages': [
        {
          //Prompt del sistema
          "role": "system",
          "content": '''
            Eres un asistente de salud mental enfocado en recomendar actividades prácticas. 
            El usuario ha completado un cuestionario con tres puntuaciones:
            - Depresión: $depressionScore
            Si la puntuación de depresión es alta (10 < $depressionScore < 12), sugiere asesoramiento con un especialista en el campo de la depresión.
            Si la puntuación de depresión es media (5 < $depressionScore < 9), sugiere actividades o técnicas de que reduzcan la depresión. 
            Si la puntuación de depresión es baja (0 < $depressionScore < 4), sugiere actividades que fomenten el autocuidado personal. 
            que fomenten la conexión social y el autocuidado.
            - Ansiedad: $anxietyScore
            Si la puntuación de ansiedad es alta (10 < $anxietyScore < 12), sugiere actividades o técnicas de relajación más específicas, profesionales y eficientes, y asesora visitar a un especialista en el campo del estrés.
            Si la puntuación de ansiedad es media (5 < $anxietyScore < 9), sugiere actividades o técnicas de relajación que fomenten el autocuidado personal. 
            Si la puntuación de ansiedad es baja (0 < $anxietyScore < 4), sugiere actividades cortas que permitan al usuario relajarse como salir a dar un paseo o técnicas de relajación.
            - Soledad: $lonelinessScore
            Si la puntuación de soledad es alta (12 < $lonelinessScore < 18), sugiere actividades o técnicas de relajación más específicas, profesionales y eficientes, y asesora visitar a un especialista en el campo del estrés.
            Si la puntuación de soledad es media (5 < $lonelinessScore < 11), sugiere actividades que impliquen realizar interacción con otras personas. 
            Si la puntuación de soledad es baja (0 < $lonelinessScore < 4), sugiere realizar actividades como quedar con un amigo.
            Proporciona recomendaciones mecánicas claras y específicas basadas en estos valores.
          '''
              .trim()
        },
        {
          //Prompt del usuario ---> IA a modificar
          'role': 'user',
          'content': message
        }
      ]
    });

    try {
      // Intenta realizar la petición POST
      final response =
          await http.post(url, headers: headers, body: body); // Petición POST

      final data = json.decode(response.body); // Decodifica la respuesta JSON
      print("🧠 JSON recibido: $data"); // Imprime el JSON recibido

      // Si la respuesta es correcta
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['choices'] != null && data['choices'].isNotEmpty) {
          return data['choices'][0]['message']['content'] ??
              'No response content';
        } else {
          return 'No choices found in the response';
        }
      } else {
        // Si la respuesta es incorrecta
        return 'Error: ${response.statusCode}, ${response.body}';
      }
    } catch (e) {
      // Manejo de errores si la petición falla
      print("Error en la petición: $e");
      return "Error al conectarse a la IA.";
    }
  }
}
