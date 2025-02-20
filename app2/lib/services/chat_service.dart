import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> sendMessage(String message) async {
    // Aquí integraríamos la API de IA (Firebase AI Extensions o Gemini)
    // Simulación de respuesta por ahora:
    return "Esto es una respuesta generada por IA para: $message";
  }

  Stream<QuerySnapshot> getMessages() {
    return _firestore.collection('messages').snapshots();
  }
}
