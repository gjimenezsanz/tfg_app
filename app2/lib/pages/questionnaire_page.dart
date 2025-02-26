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
  List<QuestionLoneliness> _questions = []; // Lista de preguntas
  final QuestionService _questionService = QuestionService();

  bool _isCompleted = false; // Indica si el cuestionario ha terminado

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
    // Método para avanzar a la siguiente pregunta
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null; // Reset opción seleccionada
      });
    } else {
      print("✅ Cuestionario completado.");
      setState(() {
        _isCompleted = true; // Marcar el cuestionario como finalizado
      });
      // Aquí puedes navegar a otra pantalla o mostrar un mensaje final
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Cuestionario"),
          //backgroundColor: Colors.black,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text("Cuestionario")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: _isCompleted
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Cuestionario terminado",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Regresar a GeneratorPage
                    },
                    child: Text("Volver a la página principal"),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  BigCard(question: _questions[_currentIndex].pregunta),
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
                      textColor: Theme.of(context).colorScheme.onPrimary,
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

class BigCard extends StatelessWidget {
  final String question; // Pregunta: _questions[_currentIndex].pregunta

  const BigCard({
    //constructor
    Key? key,
    required this.question, // Parámetro (pregunta) obligatorio
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      //color: Colors.deepPurple.shade200,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          question,
          style: style.copyWith(fontWeight: FontWeight.bold, fontSize: 20),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
