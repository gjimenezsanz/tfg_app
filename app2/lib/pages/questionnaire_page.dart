import 'package:app2/models/question_loneliness.dart';
import 'package:app2/services/question_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionPage extends StatefulWidget {
  @override
  _QuestionPageState createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  int _currentIndex = 0; // Índice de la pregunta actual
  String? _selectedOption; // Opción seleccionada
  List<QuestionLoneliness> _questions = [];
  final QuestionService _questionService = QuestionService();

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    List<QuestionLoneliness> questions =
        await _questionService.fetchQuestions();
    setState(() {
      _questions = questions;
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null; // Reset opción seleccionada
      });
    } else {
      print("✅ Cuestionario completado.");
      // Aquí puedes navegar a otra pantalla o mostrar un mensaje final
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text("Cuestionario")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Cuestionario")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _questions[_currentIndex].pregunta,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),

            // Opciones con botones de radio
            ..._questions[_currentIndex].opciones.map((opcion) {
              return ListTile(
                title: Text(opcion),
                leading: Radio<String>(
                  value: opcion,
                  groupValue: _selectedOption,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedOption = value;
                    });
                  },
                ),
              );
            }).toList(),

            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _selectedOption != null ? _nextQuestion : null,
              child: Text(_currentIndex < _questions.length - 1
                  ? "Siguiente"
                  : "Finalizar"),
            ),
          ],
        ),
      ),
    );
  }
}
