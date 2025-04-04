import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app2/models/question.dart';
import 'recommendation_page.dart';

class QuestionPage extends StatefulWidget {
  @override
  _QuestionPageState createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  int _currentIndex = 0; // Índice de la pregunta actual
  String? _selectedOption; // Opción seleccionada

  List<Question> _questions = []; // Lista de preguntas
  int _totalScore = 0; // Puntaje total
  bool _isCompleted = false; // Indica si el cuestionario ha terminado

  @override
  void initState() {
    super.initState();
    _loadQuestionsFromJson();
  }

  Future<void> _loadQuestionsFromJson() async {
    try {
      String jsonString = await rootBundle.loadString('assets/questions.json');
      Map<String, dynamic> jsonData = json.decode(jsonString);

      List<Question> questions = (jsonData["preguntas"] as List)
          .map((data) => Question.fromJson(data))
          .toList();

      setState(() {
        _questions = questions;
      });

      print("📌 Preguntas cargadas: ${_questions.length}");
    } catch (e) {
      print("❌ Error al cargar preguntas desde JSON: $e");
    }
  }

  void _saveResponse(String pregunta, String respuesta) {
    int score = _getScore(respuesta);
    _totalScore += score;
    FirebaseFirestore.instance.collection("respuestas").add({
      "pregunta": pregunta,
      "respuesta": respuesta,
      "puntaje": score,
      "timestamp": FieldValue.serverTimestamp(),
    }).then((_) {
      print("✅ Respuesta guardada en Firebase");
    }).catchError((error) {
      print("❌ Error al guardar respuesta: $error");
    });
  }

  int _getScore(String respuesta) {
    switch (respuesta) {
      case "Casi nunca":
        return 1;
      case "Algunas veces":
        return 2;
      case "A menudo":
        return 3;
      default:
        return 0;
    }
  }

  void _nextQuestion() {
    // Método para avanzar a la siguiente pregunta

    if (_selectedOption != null) {
      _saveResponse(_questions[_currentIndex].pregunta, _selectedOption!);
    }

    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null; // Reset opción seleccionada
      });
    } else {
      setState(() {
        _isCompleted = true; // Marcar el cuestionario como finalizado
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RecommendationPage(score: _totalScore),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Cuestionario"),
          backgroundColor: Colors.black,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Cuestionario"),
        backgroundColor: Colors.black,
        titleTextStyle: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primaryContainer),
      ),
      backgroundColor: const Color.fromARGB(255, 0, 15, 49),
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
                        color: Theme.of(context).colorScheme.onPrimary),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Regresar a GeneratorPage
                    },
                    child: Text("Volver a la página principal"),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              RecommendationPage(score: _totalScore),
                        ),
                      );
                    },
                    child: Text("Ver recomendaciones"),
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
                      textColor: Theme.of(context).colorScheme.primaryContainer,
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

class BigCard extends StatelessWidget {
  final String question; // Pregunta: _questions[_currentIndex].pregunta

  const BigCard({
    //constructor
    Key? key,
    required this.question, // Parámetro (pregunta) obligatorio
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      //color: Colors.deepPurple.shade200,
      color: Theme.of(context).colorScheme.primary,

      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          question,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Theme.of(context).colorScheme.onPrimary),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
