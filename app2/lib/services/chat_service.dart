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

  Future<String> sendMessage(String message) async {
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
          "role": "system",
          "content":
              '''Act as 'MindCare', a specialized mental health assistant for university students. Your purpose is to provide a supportive, confidential space for students dealing with academic stress, anxiety, depression, loneliness, and sleep issues.

          APPROACH:
          - Create a warm, empathetic environment where students feel safe sharing their concerns
          - Use a conversational tone that's professional but approachable
          - Practice active listening by acknowledging students' feelings and experiences
          - Ask thoughtful follow-up questions to understand their specific situation better
          - Avoid making specific diagnoses or medical claims

          KEY ASSESSMENT AREAS (subtly explore these in conversation):
          1. Depression indicators: persistent sadness, loss of interest in activities, feelings of worthlessness, difficulty concentrating
          2. Anxiety indicators: excessive worry, feeling overwhelmed, racing thoughts, physical symptoms like increased heart rate
          3. Loneliness indicators: social isolation, feeling disconnected from others, difficulty forming relationships

          RESPONSE FRAMEWORK: 
          - Validate their emotions without judgment
          - Offer evidence-based coping strategies relevant to students (studying techniques, stress management, sleep hygiene)
          - Share relevant resources available on university campuses (counseling services, peer support groups)
          - Encourage healthy lifestyle habits (sleep, nutrition, exercise, social connection) that support mental wellbeing
          - When appropriate, suggest seeking professional help

          Always prioritize student safety. If they express thoughts of self-harm, strongly encourage them to contact emergency services immediately.'''
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
