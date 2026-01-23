import 'package:app2/main.dart';
import 'package:app2/models/session_data.dart';
import 'package:app2/services/chat_service.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart'; // Para mostrar texto bonito
import 'package:url_launcher/url_launcher.dart'; // Para abrir enlaces externos

class CarruselFocusPage extends StatelessWidget {
  const CarruselFocusPage({Key? key}) : super(key: key);

  //Construye el prompt a partir de Hive
  Future<String> _buildFocusPrompt(BuildContext context) async {
    final box = Hive.box<SessionData>('sessionsBox');
    final sid = context.read<MyAppState>().sessionRef!.id;
    final local = box.get(sid);

    if (local != null) {
      final mood = local.mood;
      final scores = local.scores;
      final flag = local.flag;

      var prompt = '''
        You are a mental health assistant for students and your goal is to help the student as much as possible to improve their mental health.
        You are an expert in innovative study techniques to improve academic performance in students, reducing procastination and improving efficiency in studying and homework.
        Activity: Improved concentration when studying

        Context:
        Based on the following parameters collected about the student, we can advise you in the best way:
          • Mood: ${mood?.moodLabel ?? 'Unknown'} (${(mood?.value ?? 0).toStringAsFixed(2)})
          • Scores: depression=${scores?.scoreDepression ?? 0}, anxiety=${scores?.scoreAnxiety ?? 0}, stress=${scores?.scoreStress ?? 0}
          • Flag: ${flag != null ? flag.type : 'None'}
      ''';
      // Si hay un flag
      if (flag != null) {
        prompt += '\nDetected issue: ${flag.type} — "${flag.snippet}"\n';
      }

      // Petición de contenidos específicos para focus
      prompt += '''
        Please provide:
        - Three evidence-based focus techniques
        - Two short audio or video resource URLs
        - One productivity app or tool recommendation
        - Any useful external links
      ''';

      return prompt;
    }

    // Fallback si no hay datos locales
    return '''
      You are a mental health assistant for students.
      Activity: Focus improvement techniques

      Context: No local session data found.

      Please provide:
      - Three expert-backed focus techniques
      - Two YouTube video URLs
      - One illustrative image URL
      - Any useful external links
    ''';
  }

  @override
  Widget build(BuildContext context) {
    final chat = ChatService();

    return Scaffold(
      // AppBar con fondo
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/fondo1.jpg'),
              fit: BoxFit.cover,
              opacity: 0.9,
            ),
          ),
          child: AppBar(
            title: Text("Focus Recommendations"),
            backgroundColor: Colors.transparent,
            titleTextStyle: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
          ),
        ),
      ),
      // Body: fondo permanente + estados de carga + resultado
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/image2.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.4), // ajusta la opacidad a tu gusto
              BlendMode.darken, // modo de oscurecimiento
            ),
          ),
        ),
        child: FutureBuilder<String>(
          future: _buildFocusPrompt(context),
          builder: (ctx, snapPrompt) {
            if (snapPrompt.connectionState != ConnectionState.done) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapPrompt.hasError) {
              return Center(
                child: Text("Error building prompt",
                    style: TextStyle(color: Colors.white)),
              );
            }
            final prompt = snapPrompt.data!;

            return FutureBuilder<ChatResult>(
              future: chat.sendMessage(prompt),
              builder: (ctx2, snapResp) {
                // Mientras llega la respuesta del LLM
                if (snapResp.connectionState != ConnectionState.done) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapResp.hasError) {
                  return Center(
                    child: Text("Error: ${snapResp.error}",
                        style: TextStyle(color: Colors.white)),
                  );
                }
                final result = snapResp.data!;

                // Mostrar el resultado del LLM con Markdown (mejor formato)
                return Markdown(
                  padding: EdgeInsets.all(16),
                  data: result.text,
                  styleSheet: MarkdownStyleSheet(
                    p: TextStyle(color: Colors.white, fontSize: 16),
                    h3: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                    listBullet: TextStyle(color: Colors.white, fontSize: 16),
                    a: TextStyle(color: Colors.lightBlueAccent),
                  ),
                  // Manejo de enlaces
                  onTapLink: (text, href, title) {
                    if (href != null) launchUrl(Uri.parse(href));
                  },
                  selectable: true, // permite seleccionar el texto
                  softLineBreak: true, // permite saltos de línea suaves
                  // elimina el fondo blanco por defecto
                  shrinkWrap: true,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
