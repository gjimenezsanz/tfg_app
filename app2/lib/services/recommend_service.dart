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
             You are a mental health assistant focused on recommending techniques and activities that can improve the user's lifestyle to improve their mental health. 
              The user has completed a questionnaire with three scores:
              - Depression: $depressionScore
              - Anxiety: $anxietyScore
              - Loneliness: $lonelinessScore

              If the depression score is high (10 < $depressionScore < 12), you suggest counselling with a specialist in the field of depression.
              If the depression score is medium (5 < $depressionScore < 9), suggest activities or techniques to reduce depression. 
              If the depression score is low (0 < $depressionScore < 4), suggest activities that promote self-care. 

              If the anxiety score is high (10 < $anxietyScore < 12), suggest more specific, professional and efficient relaxation activities or techniques, and advise to visit a specialist in the field of stress.
              If the anxiety score is medium (5 < $anxietyScore < 9), suggest relaxation activities or techniques that promote self-care. 
              If the anxiety score is low (0 < $anxietyScore < 4), suggest short activities that allow the user to relax such as going for a walk or simple relaxation techniques that can be done in a few minutes daily.

              If the loneliness score is high (12 < $lonelinessScore < 18), suggest more specific, professional, and efficient socialisation activities or techniques, advises to visit an expert to help with social isolation.
              If the loneliness score is medium (5 < $lonelinessScore < 11), suggest activities that involve interactions with other people, or try new group activities. 
              If the loneliness score is low (0 < $lonelinessScore < 4), suggest activities that involve interaction with another person, such as meeting a friend.
              
              It provides clear and specific mechanical recommendations based on these values.
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
