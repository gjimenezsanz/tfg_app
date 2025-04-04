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
    return Scaffold(
      appBar: AppBar(title: Text("Chat con IA")),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: _response == null
                  ? Text("Escribe un mensaje para comenzar")
                  : Text(_response!, style: TextStyle(fontSize: 18)),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(labelText: "Escribe aquí..."),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
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
