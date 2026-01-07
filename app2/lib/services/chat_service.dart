import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform; // Para verificar un servidor distinto
import 'package:flutter/foundation.dart'
    show kIsWeb; // Para verificar un servidor distinto

class ChatService {
  final String baseUrl = 'https://openrouter.ai/api/v1'; // URL base
  final String apiKey =
      "REDACTED_OPENROUTER_KEY"; //API Key OpenRouter
  //final String referer = '<url>'; // Opcional
  //final String title = '<title>'; // Opcional

  Future<ChatResult> sendMessage(String message) async {
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
          'meta-llama/llama-3.3-70b-instruct:free', // Modelo de IA a utilizar

      'messages': [
        {
          "role": "system",
          "content":
              '''Act as specialized mental health assistant for university students. Your purpose is to provide a supportive, confidential space for students dealing with academic anxiety, depression, stress, and sleep issues.

          APPROACH:
          - Create a warm, empathetic environment where students feel safe sharing their concerns
          - Use a conversational tone that's professional but approachable
          - Practice active listening by acknowledging students' feelings and experiences
          - Ask thoughtful follow-up questions to understand their specific situation better
          - Avoid making specific diagnoses or medical claims

          KEY ASSESSMENT AREAS (subtly explore these in conversation):
          1. Depression indicators: persistent sadness, loss of interest in once‐enjoyed activities, frequent fatigue or low energy, feelings of worthlessness, difficulty concentrating, changes in appetite or weight, recurrent thoughts of hopelessness.
          2. Anxiety indicators: excessive worry, feeling on edge or jumpy, racing thoughts under pressure, sleep onset difficulties, physical symptoms like increased heart rate or moments of shortness of breath.
          3. Stress indicators: persistent muscle tension, sleep disturbances or insomnia, frequent headaches or stomachaches, irritability and low frustration tolerance, difficulty unwinding after university.

          RESPONSE FRAMEWORK: 
          - Validate their emotions without judgment
          - Offer evidence-based coping strategies relevant to students (studying techniques, stress management, sleep hygiene)
          - Share relevant resources available on university campuses (counseling services, peer support groups)
          - Encourage healthy lifestyle habits (sleep, nutrition, exercise, social connection) that support mental wellbeing
          - When appropriate, suggest seeking professional help

          Always prioritize student safety. If they express thoughts of self-harm, strongly encourage them to contact emergency services immediately.
    
        You are a mental health assistant. When producing user recommendations, also analyze your response and detect any indications of anxiety, depression, or stress. At the end of your reply, output a JSON object exactly like:
          {
            "flags": [
              {"type": "anxiety",    "snippet": "<exact sentence indicating anxiety>"},
              {"type": "depression", "snippet": "<exact sentence indicating depression>"},
              {"type": "stress", "snippet": "<exact sentence indicating stress>"}
            ]
          }

          If you find no sentence indicating any of these conditions, output:
          {
            "flags": []
          }

          Do NOT output a flag with type "none" or snippet "None". Only include entries in the array when a genuine snippet is found.

          '''
        },
        {
          //Prompt del usuario ---> IA a modificar
          'role': 'user',
          'content': message
        }
      ]
    });
    try {
      final response = await http.post(url, headers: headers, body: body);
      // Si la respuesta es un error de límite de peticiones
      if (response.statusCode == 429) {
        return ChatResult(
          text:
              "Has alcanzado el límite de peticiones gratuitas de hoy. Por favor inténtalo mañana.",
          flags: [],
        );
      }
      if (response.statusCode != 200) {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }

      final data = json.decode(response.body);

      // Extraer la respuesta completa de la IA
      final fullReply = data['choices'][0]['message']['content'] as String;

      // Separa recomendaciones vs JSON de flags
      // Divide el texto en dos partes: recomendaciones y bloque JSON. Tras el salto de linea empieza el JSON
      final parts = fullReply.split(RegExp(r'\n\{', multiLine: true));
      // La primera parte contiene el texto de recomendaciones
      final recommendationsText = parts.first.trim();
      // La segunda parte contiene el bloque JSON de flags, se le añade { para que sea un JSON válido
      final jsonText = '{' + parts.last.trim();

      // Parsear el bloque JSON de flags
      Map<String, dynamic> flagsBlock;
      try {
        // Decodificar el JSON: texto a mapa
        //Key: flags
        flagsBlock = json.decode(jsonText) as Map<String, dynamic>;
      } catch (_) {
        // Si falla: devuelve un bloque vacío
        flagsBlock = {'flags': []};
      }
      // Convertir Map a lista de mapas:
      //  flagsBlock['flags'] accedemos al Value de flag, y comprobamos que sea una lista
      // Cada flag es un mapa con => "type" y "snippet"
      /*  for (var map in flags) {
            String tipo = map['type'];
            String fragmento = map['snippet'];
            ...
          }
      // Ejemplo de JSON respuesta de la IA:
          {
            "flags": [
              {"type": "anxiety", "snippet": "I feel overwhelmed with my studies."},
              {"type": "depression", "snippet": "I have lost interest in my hobbies."}
            ]
          }
      */
      final flags =
          (flagsBlock['flags'] as List<dynamic>).cast<Map<String, dynamic>>();

      // Devolver objeto estructurado: recomendaciones y mapa de flags
      return ChatResult(
        text: recommendationsText, // Texto de recomendaciones
        flags: flags.map((m) => Flag.fromMap(m)).toList(), // Lista de flags
      );
    } catch (e) {
      print("Error en la petición: $e");
      return ChatResult(text: "Error al conectarse a la IA.", flags: []);
    }
  }
}

// Clase para almacenar el resultado de la conversación con la IA :
//  text (lo que muestras en pantalla) y flags (lo que guardas en Firebase o Hive)
class ChatResult {
  final String text; //texto de recomendaciones
  final List<Flag> flags; //lista de Flag(type, snippet)
  ChatResult({required this.text, required this.flags});
}

class Flag {
  final String type;
  final String snippet;
  Flag({required this.type, required this.snippet});
  factory Flag.fromMap(Map<String, dynamic> m) => Flag(
        type: m['type'] as String,
        snippet: m['snippet'] as String,
      );
}
