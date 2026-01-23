import "package:app2/main.dart";
import "package:app2/models/session_data.dart";
import "package:flutter/material.dart";
import "package:hive/hive.dart";
import "package:provider/provider.dart";
import 'package:app2/services/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatService _chatService = ChatService();
  bool _isLoading = false; // Estado de carga
  String? _error; // Para mostrar errores en la UI

  final TextEditingController _controller =
      TextEditingController(); // Controlador del campo de texto
  String? _response; //Respuesta texto
  List<Flag>?
      _detectedFlags; // Lista de flags detectados => Para sacar los flagas por pantalla
  final List<Map<String, dynamic>> _history =
      []; // Historial de mensajes previos

  void _sendMessage() async {
    final userMessage = _controller.text.trim(); // Mensaje del usuario
    if (userMessage.isEmpty) return; // No enviar mensajes vacíos
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Envia el mensaje: mostramos indicación de “Pensando...”
      setState(() {
        _response = "Pensando...";
      });

      // Prepara el historial reciente (últimos 6 mensajes)
      final recentHistory = _history.length <= 6
          ? List<Map<String, dynamic>>.from(_history)
          : _history.sublist(_history.length - 6);

      // Envía el mensaje del usuario al servicio de chat
      final response =
          await _chatService.sendMessage(userMessage, history: recentHistory);
      //userMessage se refiere a _textController.text.trim() sin mensajes vacíos
      // Respuesta:
      //  response.text: el texto de recomendaciones
      //  response.flags: la lista de flags detectados

      setState(() {
        // Actualiza la respuesta en pantalla
        _response = response.text; // Muestra el texto de recomendaciones
        _detectedFlags = response.flags; // Guarda los flags detectados
        _history.add({
          'role': 'user',
          'content': userMessage
        }); // Añade el mensaje del usuario al historial
        _history.add({
          'role': 'assistant',
          'content': response.text
        }); // Añade la respuesta de la IA al historial
      });

      // Obtener la sesión global desde MyAppState (Provider)
      // Referencia a la sesión actual
      final sessionRef = context.read<MyAppState>().sessionRef;
      // Obtener ID de sesión para Hive
      final sid = sessionRef?.id;

      if (sessionRef != null && sid != null) {
        // Guardar recommendations en Firestore
        try {
          await sessionRef.update({
            'recommendations': response.text,
            'timestamp': FieldValue.serverTimestamp(),
          });
        } catch (e) {
          print('Error guardando recommendations en sesión: $e');
        }

        // Si hay flags, preparamos la lista de mapas para guardar en Firestore
        if (response.flags.isNotEmpty) {
          final Flag flag0 = response.flags.first; // Primer flag
          try {
            await sessionRef.update({
              'flags': {
                'prompt': userMessage,
                'snippet': flag0.snippet,
                'type': flag0.type,
              },
              'timestamp': FieldValue.serverTimestamp(),
            });
            print('Flag guardada en sesión Firestore: ${flag0.type}');
          } catch (e) {
            // Manejo de errores al guardar el flag
            print('Error guardando flag en sesión: $e');
          }

          // Guardar en Hive
          var box = Hive.box<SessionData>('sessionsBox');
          final local = box.get(sid); // Obtiene la sesión local
          // Si ya existe, actualizamos la flag
          final newFlagData = FlagData(
            prompt: userMessage,
            snippet: flag0.snippet,
            type: flag0.type,
          );
          if (local != null) {
            local.flag = newFlagData;
            local.recommendations = response.text;
            local.timestamp = DateTime.now();
            await local.save();
          } else {
            // Si no existe, creamos sessionData y guardamos:
            final sessionData = SessionData(
              timestamp: DateTime.now(),
              recommendations: response.text,
              flag: newFlagData,
            );
            await box.put(sid, sessionData);
          }
          final saved = box.get(sid);
          print(
              'HIVE[$sid] recommendations="${saved?.recommendations}" flag=${saved?.flag?.type}');
        } else {
          // Si no hay flags, mostramos un mensaje
          print('No se detectaron flags');
        }
      } else {
        // Si no hay sesión activa, mostramos un mensaje
        print('No hay sesión activa');
      }

      // Limpia el campo de texto
      _controller.clear();
    } catch (e) {
      // Manejo de errores al enviar el mensaje o guardar los datos
      print('Error enviando mensaje o guardando datos: $e');
      setState(() {
        _error = 'Error al comunicarse con la IA';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          // Ponemos la imagen de fondo aquí
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/fondo2.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: AppBar(
            title: Text("Assistant Chat"),
            backgroundColor: Colors.transparent,
            titleTextStyle: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: colorScheme.primaryContainer,
            ),
          ),
        ),
      ),
      body: SizedBox.expand(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/fondo1.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: _response == null
                      ? Text(
                          "Writte a message to start a conversation with your assistant",
                          style: TextStyle(
                            fontSize: 18,
                            color: colorScheme.onPrimary,
                            fontStyle: FontStyle.italic,
                          ),
                        )
                      : Text(
                          _response!,
                          style: TextStyle(
                            fontSize: 18,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller, // Texto del usuario
                        decoration: InputDecoration(
                          labelText: "Text here...",
                          labelStyle: TextStyle(
                            color: colorScheme.primaryContainer,
                            fontSize: 18,
                          ),
                        ),
                        style: TextStyle(color: colorScheme.primaryContainer),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      color: colorScheme.primary,
                      onPressed:
                          _sendMessage, // Envía el mensaje al presionar el botón
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
