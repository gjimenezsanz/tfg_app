import "package:app2/main.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import 'package:app2/services/chat_service.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatService _chatService = ChatService();
  final TextEditingController _controller = TextEditingController();
  String? _response;

  void _sendMessage() async {
    // Envia el mensaje
    setState(() {
      _response = "Pensando...";
    });

    final response = await _chatService.sendMessage(_controller.text);

    setState(() {
      // Actualiza la respuesta
      _response = response;
    });

    _controller.clear(); // Limpia el campo de texto
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 29, 49),
      appBar: AppBar(
        title: Text("Assistant Chat"),
        backgroundColor: Colors.black,
        titleTextStyle: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primaryContainer),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: _response == null
                  ? Text(
                      "Writte a message to start a conversation with your assistant",
                      style: TextStyle(
                          fontSize: 18,
                          color: colorScheme.onPrimary,
                          fontStyle: FontStyle.italic),
                    )
                  : Text(
                      _response!,
                      style:
                          TextStyle(fontSize: 18, color: colorScheme.onPrimary),
                    ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                        labelText: "Text here...",
                        labelStyle: TextStyle(
                            color: colorScheme.primaryContainer, fontSize: 18)),
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
    );
  }
}
